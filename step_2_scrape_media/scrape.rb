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

def shoot_pages(browser, screens, host, slug)
  browser.nav(id: 'scrollytelling-navigation').as.each_with_index do |link, index|
    browser.goto link.attribute_value('href')
    uri = URI(browser.url)
    filename = "#{slug}-page#{index + 1}_#{uri.fragment}.png"

    browser.section(id: uri.fragment).wait_until { |s| s.class_name.include? 'active' }
    browser.screenshot.save screens.join(filename)

    system("exiftool
      -Creator='Joost Baaij'
      -CreatorTool='#{cap.browser_name} #{cap.version}'
      -Description='Screenshot of a single page in the story. Created for archival purposes.' 
      -Website='#{browser.url}'
      -DigitalSourceType=softwareImage
      -FeaturedOrganisationName=Scrollytelling
      -Keywords=screenshot,chrome,pageflow,web
      -ContactInfo=Website=scrollytelling.com,Email=info@scrollytelling.com"
    )
  rescue Watir::Wait::TimeoutError => error
    warn error.to_s
    next
  end
end

def uri_path(url)
  URI.unescape(url)
    .sub('https://', '')
    .sub(/\?\d+\z/, '')
end

index = JSON.parse(account.index.read)
index['entries'].each do |entry|

  host = entry['host']
  slug = entry['slug']
  puts "== scraping: #{entry['canonical_url']}"

  %w(video_files image_files audio_files).each do |filetype|
    entry[filetype] = []

    browser.goto "https://app.scrollytelling.io/editor/entries/#{slug}/files/#{filetype}.json"

    # grep through the entire thing and snatch everything that looks like a bucket.
    browser.text
      .scan(\w*\.scrollytelling\.com.*?\d{3}\/\d{3}\/\d{3})
      .sort
      .uniq.each do |path|
        dest = account.root.join(from)
        from = path.sub('output.scrollytelling.io', 'storyboard-pageflow-production-out')
        system("aws s3 sync", "s3://#{from}", "#{dest}", "--no-progress")

        puts "  s3://#{from} ➡️  #{dest}"
      end

    JSON
      .parse(browser.text)
      .each do |file|

      if file['original_url']
        # add the file's path how it will be in the archive.
        file['path'] = uri_path(file['original_url'])
        # strip the first slash, otherwise absolute dir is assumed
        pathname = account.root.join(file['path'])
        file['sha256'] = Digest::SHA256.file(pathname)
        file['size'] = pathname.size
        file['content_type'] ||= MimeMagic.by_path(pathname).type
      end

      file['sources']&.each do |source|
        if (source['src'])
          # change https://output.scroll to /output.scroll
          source['path'] = uri_path(source.delete('src'))
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
  browser.screenshot.save screens.join("#{host}-#{slug}")

  shoot_pages(browser, screens, host, slug) if browser.nav(id: 'scrollytelling-navigation').exists?

  cap = browser.driver.capabilities
  system("
    for image in #{screens}
    do
      mogrify -format jpg -interlace Plane -quality 85 $image
      convert $image -thumbnail 280x -strip ${image/.png/.jpg}
    done
  ")

  puts

rescue Watir::Wait::TimeoutError => error
  warn error.to_s
  next
end
