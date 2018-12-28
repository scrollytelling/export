require 'time'
require 'json'

Dir.glob("../entries/*").each do |account|
  next unless File.exist?("#{account}/index.json")
  json = File.read("#{account}/index.json")
  index = JSON.parse(json)

  index['entries'].each do |entry|
    time = Time.iso8601 entry['published_at']
    story = "#{account}/#{entry['slug']}.html"
    File.utime time, time, story if File.exist?(story)
  end
end
