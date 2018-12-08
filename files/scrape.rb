require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'json'
require 'find'

browser = Watir::Browser.new :chrome, headless: true
browser.goto 'https://app.scrollytelling.io/admin/login'

browser.text_field(label: 'Email*').set 'joost@spacebabies.nl'
browser.text_field(label: 'Password*').set ''
browser.button(value: 'Login').click

Dir.glob("../entries/hu.scrollytelling.io/*").each do |path|
  puts
  puts "== path: #{path}"
  dirs = path.split('/')

  %w(video_files image_files audio_files).each do |filetype|
    browser.goto "https://app.scrollytelling.io/editor/entries/#{dirs[-1]}/files/#{filetype}.json"

    JSON.parse(browser.text).each do |file|
      bucket = /\w*\.scrollytelling\.com.*\d{3}\/\d{3}/.match(file['url'])[0]
      system("aws s3 sync s3://#{bucket} #{path}/../#{bucket}")
    end

    File.open("#{path}/#{filetype}.json", 'wt') do |file|
      file.write browser.text
    end
  end

  browser.goto "https://#{dirs[-2]}/#{dirs[-1]}"
  File.open("#{path}/index.html", 'wt') do |file|
    file.write browser
      .html
      .gsub('https://scrollytelling.link', '/scrollytelling.link')
      .gsub('http://media.scrollytelling.com', '/media.scrollytelling.com')
      .gsub('https://media.scrollytelling.com', '/media.scrollytelling.com')
      .gsub('https://output.scrollytelling.com', '/output.scrollytelling.com')
  end

  system("/bin/gzip --force --keep #{path}/index.html")
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
