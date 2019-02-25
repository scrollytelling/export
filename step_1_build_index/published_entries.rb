require 'fileutils'
require 'json'

require_relative "../lib/scrollytelling/export/account"
require_relative "../lib/scrollytelling/export/export"
require_relative "../lib/scrollytelling/export/story"

hostname = ENV.fetch('ACCOUNT')
puts
puts "✨ Exporting #{hostname} scrollies!"

revisions = Pageflow::Revision
  .published
  .includes(entry: [{account: :themings}], storylines: { chapters: [:pages] })
  .where(pageflow_themings: {cname: hostname})
  .order(published_at: :desc)

revisions.each_with_index do |revision, counter|
  export = Scrollytelling::Export::Export.new revision
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
