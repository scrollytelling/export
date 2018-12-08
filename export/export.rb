require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'time'

Dir.glob("../entries/*/*").each do |path|
  next if path =~ /beeldengeluid/

  host, slug = path.split('/')[2,2]
  puts "https://#{host}/#{slug}"
  response = HTTP.get "https://#{host}/#{slug}"
  index = response.body.to_s
    .gsub('https://scrollytelling.link', '/scrollytelling.link')
    .gsub('http://media.scrollytelling.com', '/media.scrollytelling.com')
    .gsub('https://media.scrollytelling.com', '/media.scrollytelling.com')
    .gsub('https://output.scrollytelling.com', '/output.scrollytelling.com')

  File.open("#{path}/index.html", 'wt') do |file|
    file.write(index)
  end
end
