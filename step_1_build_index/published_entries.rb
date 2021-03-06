hostname = ARGV[0]
abort "Missing argument: cname of the account to export." if hostname.nil?

require 'fileutils'
require 'json'

require_relative "../lib/scrollytelling/export/account"
require_relative "../lib/scrollytelling/export/exporter"
require_relative "../lib/scrollytelling/export/story"

puts
puts "✨ Exporting #{hostname} scrollies!"

revisions = Pageflow::Revision
  .published
  .includes(entry: [{account: :themings}], storylines: { chapters: [:pages] })
  .where(pageflow_themings: {cname: hostname})
  .order(published_at: :desc)

revisions.each_with_index do |revision, counter|
  export = Scrollytelling::Export::Exporter.new revision
  account = Scrollytelling::Export::Account.new hostname
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

  # Let others store a archive copy as well.e
  # TODO only allow one submission per month or so.
  #  Archive.new(export).submit_all
end
