require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'json'

$account = Scrollytelling::Export::Account.new ENV.fetch('ACCOUNT', 'stories.scrollytelling.com')

index = JSON.parse($account.index.read)

index['entries'].each do |entry|
  story = Scrollytelling::Export::Story.new(entry)
  screenshot = Scrollytelling::Export::Screenshot.new story
  entry['screenshots'] = screenshot.create_all!
end

$account.index.write(JSON.pretty_generate(index), mode: 'wt')
