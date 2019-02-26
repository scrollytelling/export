#!/usr/bin/env ruby

hostname = ARGV[0]
abort "Missing argument: cname of the account to export." if hostname.nil?

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'json'

$account = Scrollytelling::Export::Account.new hostname

index = JSON.parse($account.index.read)

index['entries'].each do |entry|
  story = Scrollytelling::Export::Story.new(entry)
  screenshot = Scrollytelling::Export::Screenshot.new story
  entry['screenshots'] = screenshot.create_all!
end

$account.index.write(JSON.pretty_generate(index), mode: 'wt')
