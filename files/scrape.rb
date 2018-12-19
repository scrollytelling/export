require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'json'
require 'find'

browser = Watir::Browser.new :chrome, headless: true
browser.goto 'https://app.scrollytelling.io/admin/login'

browser.text_field(label: 'Email*').set 'joost@spacebabies.nl'
browser.text_field(label: 'Password*').set '9tzRFz9TS9eH'
browser.button(value: 'Login').click

account = 'scroll.lab.nos.nl'

Dir.glob("../entries/#{account}/*").each do |path|

  host, slug = path.split('/')[2,2]
  next if slug.include? '.'
  puts
  puts "== path: #{path}"

  match_bucket = /\w*\.scrollytelling\.com.*\d{3}\/\d{3}/

  %w(video_files image_files audio_files).each do |filetype|
    browser.goto "https://app.scrollytelling.io/editor/entries/#{slug}/files/#{filetype}.json"
    files = JSON.parse(browser.text)

    files.each do |file|
      if (url = file['url'])
        bucket = url[match_bucket]
        system("aws s3 sync s3://#{bucket} #{path}/../#{bucket}")
      end

      if (poster_url = file['poster_url'])
        bucket = poster_url[match_bucket]
        system("aws s3 sync s3://#{bucket} #{path}/../#{bucket}")
      end

      file['sources']&.each do |source|
        if (src_url = source['src'])
          bucket = src_url[match_bucket]
          source = bucket.sub('output.scrollytelling.com', 'storyboard-pageflow-production-out')
          system("aws s3 sync s3://#{source} #{path}/../#{bucket}")
        end
      end
    end

    index = JSON.parse(File.read("../entries/#{account}/index.json"))
    entry = index['entries'].find { |entry| entry['slug'] == slug }
    next if entry.nil?

    entry[filetype] = files
    File.open("../entries/#{account}/index.json", 'wt') do |file|
      file.write JSON.pretty_generate(index)
    end
  end

  browser.goto ['https:/', host, slug].join('/')

  entry_css_link = browser.element(tag_name: 'link', data_name: 'entry')
  if entry_css_link.exists?
    FileUtils.mkdir_p "#{path}/../scrollytelling.link/entries"
    entry_css_href = entry_css_link.attribute_value('href').sub(/\?.*\z/, '')
    Dir.chdir("#{path}/../scrollytelling.link/entries") do
      system("/usr/bin/curl -O \"#{entry_css_href}\"")
    end
  end

  File.open("#{path}/index.html", 'wt') do |file|
    file.write browser
      .html
      .gsub('https://scrollytelling.link', '/scrollytelling.link')
      .gsub('http://media.scrollytelling.com', '/media.scrollytelling.com')
      .gsub('https://media.scrollytelling.com', '/media.scrollytelling.com')
      .gsub('https://output.scrollytelling.com', '/output.scrollytelling.com')
      .gsub('href="/entries', 'href="/scrollytelling.link/entries')
  end

  system("/bin/gzip --force --keep #{path}/index.html #{path}/index.json")
  FileUtils.mkdir_p "#{path}/../scrollytelling.link"
  FileUtils.cp_r '../assets', "#{path}/../scrollytelling.link"

  checksums = ''
  Dir.chdir(path) do
    Find.find('.') do |file|
      if FileTest.file?(file)
        checksums << `/usr/bin/sha256sum --tag #{file}`
      end
    end
  end

  File.open("#{path}/CHECKSUMS", 'wt') do |file|
    file.write(checksums)
  end
end
