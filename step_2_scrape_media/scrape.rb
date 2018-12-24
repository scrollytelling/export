require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'json'
require 'find'
require 'pathname'
require 'fileutils'
require 'uri'

browser = Watir::Browser.new :chrome,
  headless: true,
  options: { args: ['--window-size=1600,1080'] }
browser.goto 'https://app.scrollytelling.io/admin/login'

browser.text_field(label: 'Email*').set ENV.fetch('EMAIL', 'joost@spacebabies.nl')
browser.text_field(label: 'Password*').set ENV.fetch('PASSWORD')
browser.button(value: 'Login').click

Account = Struct.new(:host) do
  def root
    Pathname.new("#{__dir__}/../entries/#{host}")
  end
  def assets_path
    root.join('scrollytelling.link')
  end
  def output_path
    root.join('output.scrollytelling.com')
  end
  # it's not the indexpage of a story, but index for the entire account.
  def index
    root.join("index.json")
  end
end

account = Account.new ENV.fetch('ACCOUNT', 'app.scrollytelling.com')

# Sync a 'directory' on S3 to local and show what's happening.
def sync(bucket, source:nil, account:)
  from = source || bucket
  dest = account.root.join(bucket)
  puts "  s3://#{from} ➡️  #{dest}"
  system("aws s3 sync \"s3://#{from}\" \"#{dest}\" --no-progress")
end

def shoot_pages(browser, screens, host, slug)
  browser.nav(id: 'scrollytelling-navigation').as.each_with_index do |link, index|
    browser.goto link.attribute_value('href')
    uri = URI(browser.url)

    browser.section(id: uri.fragment).wait_until { |s| s.class_name.include? 'active' }
    browser.screenshot.save screens.join(
      "#{slug}-page#{index + 1}_#{uri.fragment}-chrome71.png"
    )
  rescue Watir::Wait::TimeoutError => error
    warn error.to_s
    next
  end
end

def uri_path(url)
  URI.unescape(url)
    .sub('https:/', '..')
    .sub(/\?\d+\z/, '')
end

index = JSON.parse(account.index.read)
index['entries'].each do |entry|

  host = entry['host']
  slug = entry['slug']
  puts "== scraping: #{entry['canonical_url']}"

  match_bucket = /\w*\.scrollytelling\.com.*\d{3}\/\d{3}/

  %w(video_files image_files audio_files).each do |filetype|
    entry[filetype] = []

    # puts "   https://app.scrollytelling.io/editor/entries/#{slug}/files/#{filetype}.json"
    browser.goto "https://app.scrollytelling.io/editor/entries/#{slug}/files/#{filetype}.json"
    files = JSON.parse(browser.text)
    puts "   #{filetype}: #{files.length}"

    files.each do |file|

      if (url = file['original_url'])
        sync url[match_bucket], account: account

        # add the file's path how it will be in the archive.
        file['path'] = uri_path(url)
        # strip the first slash, otherwise absolute dir is assumed
        pathname = account.root.join(file['path'][1..-1])
        file['sha256'] = Digest::SHA256.file(pathname)
        file['size'] = pathname.size
        file['content_type'] ||= MimeMagic.by_path(pathname).type
      end

      if (file['poster_url'])
        sync file['poster_url'][match_bucket], account: account
      end

      file['sources']&.each do |source|
        if (source['src'])
          # change https://output.scroll to /output.scroll
          source['path'] = uri_path(source.delete('src'))

          sync source['path'][match_bucket],
            source: source['path'][match_bucket].sub('output.scrollytelling.com', 'storyboard-pageflow-production-out'),
            account: account
        end
      end

      entry[filetype] << file.slice(
        'content_type',
        'file_name',
        'height',
        'id',
        'path',
        'rights',
        'sha256',
        'size',
        'sources',
        'variants',
        'width'
      )
    end

    # Go into each synced file to replace hard-coded URLs. Sigh.
    system("find #{account.root} -name '*.m3u8' -print0 | xargs -0r sed -i -e 's\\https://output.scrollytelling.io\\/output.scrollytelling.com\\g'")
    system("find #{account.root} -name '*.mpd' -print0 | xargs -0r sed -i -e 's\\https://output.scrollytelling.io\\/output.scrollytelling.com\\g'")
    system("find #{account.root} -name '*.css' -print0 | xargs -0r sed -i -e 's\\//scrollytelling.link\\/scrollytelling.link\\g'")
    system("find #{account.root} -name '*.js' -print0 | xargs -0r sed -i -e 's\\//scrollytelling.link\\/scrollytelling.link\\g'")

    account.index.write(JSON.pretty_generate(index), mode: 'wt')
  end

  story_path = account.root.join(slug)
  screens = story_path.join('screens')
  FileUtils.rmtree screens
  FileUtils.mkdir_p screens

  browser.goto ['https:/', host, slug].join('/')

  # The multimedia alert is very in the way and does not add anything.
  browser.execute_script("document.querySelectorAll('.multimedia_alert').forEach(function(item){item.remove()})")
  browser.wait_until { |b| b.body.class_name.include? 'finished-loading' }
  browser.screenshot.save screens.join(
    "#{host}-#{slug}-chrome71.png"
  )

  shoot_pages(browser, screens, host, slug) if browser.nav(id: 'scrollytelling-navigation').exists?

  system("cd #{screens}; mogrify -format jpg -interlace Plane -quality 85 *.png; rm *.png")

  story_index = story_path.join('index.html')
  story_index.write(browser
    .html
    .gsub('https://scrollytelling.link', '/scrollytelling.link')
    .gsub('http://media.scrollytelling.com', '/media.scrollytelling.com')
    .gsub('https://media.scrollytelling.com', '/media.scrollytelling.com')
    .gsub('https://output.scrollytelling.com', '/output.scrollytelling.com')
    .gsub('href="/entries', 'href="/scrollytelling.link/entries'),
  mode: 'wt')

  %w(index.html index.json).each do |file|
    system("/bin/gzip --force --keep #{account.root.join(file)}")
  end

  entry_css_link = browser.element(tag_name: 'link', data_name: 'entry')
  if entry_css_link.exists?
    FileUtils.mkdir_p account.assets_path.join('entries')

    browser.goto entry_css_link.attribute_value('href')
    entry_css_path = account.assets_path.join('entries', "#{slug}.css")
    entry_css_path.write(browser.text.gsub('https:/', ''), mode: 'wt')
  end

  system("/bin/gzip --force --keep --recursive #{account.assets_path.join('entries', '*.css')}")

  puts

rescue Watir::Wait::TimeoutError => error
  warn error.to_s
  next
end
