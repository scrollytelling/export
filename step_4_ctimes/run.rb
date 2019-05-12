#!/usr/bin/env ruby

hostname = ARGV[0]
abort "Missing argument: cname of the account to export." if hostname.nil?

require 'time'
require 'json'

require_relative "../lib/scrollytelling/export/account"

account = Scrollytelling::Export::Account.new hostname
index = JSON.parse(account.index.read)
index['entries'].each do |entry|
  puts entry['slug']
  time = Time.iso8601 entry['published_at']

  dir = account.root.join(entry['slug'])
  File.utime time, time, dir if File.exist?(dir)
  file = dir.join('index.html')
  File.utime time, time, file if File.exist?(file)
  file = dir.join('original.html')
  File.utime time, time, file if File.exist?(file)
end
