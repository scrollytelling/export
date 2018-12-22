require 'time'
require 'json'

Dir.glob("../entries/*").each do |account|
  json = File.read("#{account}/index.json")
  index = JSON.parse(json)

  index['entries'].each do |entry|
    time = Time.iso8601 entry['published_at']
    story = [account, entry['slug']].join('/')
    File.utime time, time, story

    ['index.html', 'index.html.gz'].each do |file|
      path = [story, file].join('/')
      File.utime time, time, path if File.exist?(path)
    end
  end
end
