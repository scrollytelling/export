#!/usr/bin/env ruby

hostname = ARGV[0]
abort "Missing argument: cname of the account to export." if hostname.nil?

require 'time'
require 'json'

require_relative "../lib/scrollytelling/export/account"

account = Scrollytelling::Export::Account.new hostname
index = JSON.parse(account.index.read)
index['entries'].each do |entry|
  time = Time.iso8601 entry['published_at']
  story = "#{entry['slug']}/index.html"
  File.utime time, time, story if File.exist?(story)
end
