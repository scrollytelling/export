require 'rubygems'
require 'fileutils'
require 'json'
require 'open3'
require 'http'

require_relative './archive'
require_relative './export'
require_relative '../lib/account'
require_relative '../lib/bucket_downloader'

hostname = ENV.fetch('ACCOUNT')
puts
puts "✨ Exporting #{hostname} scrollies!"

revisions = Pageflow::Revision
  .published
  .includes(entry: [{account: :themings}], storylines: { chapters: [:pages] })
  .where(pageflow_themings: {cname: hostname})
  .order(published_at: :desc)

revisions.each_with_index do |revision, counter|
  export = Export.new revision
  account = Account.new hostname
  account.output_directories!(export.slug)

  if account.index.exist?
    index = JSON.parse(account.index.read)
    index['entries'] << export.entry_attributes
  else
    index = export.account_attributes
  end

  puts "[#{counter + 1}/#{revisions.length}] #{export.canonical_url}"

  File.open(account.index.to_path, 'wt') do |file|
    file.write(JSON.pretty_generate(index))
  end

  account.archive_path.join('urls.txt').open('a+t') do |manifest|
    manifest.puts export.canonical_url
  end

  account.archive_path.join('media.txt').open('a+t') do |manifest|
    export.audio_files.each do |file|
      manifest.puts file['url'].sub(/\?\d*\z/, '')
      manifest.puts file['sources'].map { |source| source['url'] }
    end
  end

  # Let others store a archive copy as well.e
  # TODO only allow one submission per month or so.
  #  Archive.new(export).submit_all
end
