require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'time'

if ARGV.empty?
  puts "URL to a Scrolly after this script"
  exit
end

uri = HTTP::URI.parse(ARGV[0])
Dir.mkdir(uri.host) unless File.exist?(uri.host)

response = HTTP.get(ARGV[0])
index = response.body.to_s
  .gsub('https://scrollytelling.link', '/scrollytelling.link')
  .gsub('http://media.scrollytelling.com', '/media.scrollytelling.com')
  .gsub('https://media.scrollytelling.com', '/media.scrollytelling.com')
  .gsub('https://output.scrollytelling.com', '/output.scrollytelling.com')

slug = uri.path
filename = "#{uri.host}/#{slug}.html"
File.truncate(filename, 0)
IO.write(filename, index)

# download all files used in the story
%w(video_files audio_files text_track_files image_files).each do |file_type|
  response = HTTP.get("https://app.scrollytelling.io/editor/entries/#{slug}/files/#{file_type}.json")
  IO.write("#{uri.host}/#{file_type}.json", response.body.to_s) if response.code == 200
end
