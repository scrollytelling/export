require 'rubygems'
require 'fileutils'
require 'json'
require 'open3'
require 'http'

require_relative './archive'
require_relative './export'
require_relative '../lib/account'

revisions = Pageflow::Revision
  .published
  .joins(:entry)
  .includes(entry: [:account], storylines: { chapters: [:pages] })
  .order(published_at: :desc)

revisions.each_with_index do |revision, counter|
  export = Export.new revision
  account = Account.new export.host
  account.output_directories!
  FileUtils.mkdir_p account.root.join(export.slug)

  if account.index.exist?
    index_text = account.index.read
    # if the index already has our story, skip.
    next if index_text.include?(export.entry.slug)
    attributes = JSON.parse(index_text)
  else
    attributes = export.default_attributes
  end

  puts "[#{counter + 1}/#{revisions.length}] #{export.canonical_url}"

  # stdout, stderr, status = Open3.capture3("wget",
  #   "--adjust-extension",
  #   "--convert-links",
  #   "--domains=\"#{export.host},scrollytelling.link,media.scrollytelling.com,output.scrollytelling.com\"",
  #   "--mirror",
  #   "--page-requisites",
  #   # "--reject=audio,index.html,robots.txt,videos",
  #   "--span-hosts",
  #   "--no-parent",
  #   "--timestamping",
  #   "--verbose",
  #   export.canonical_url, chdir: account.root
  # )
  # account.root.join('reports', 'crawler.out.log').write(stdout, mode: 'at')
  # account.root.join('reports', 'crawler.err.log').write(stderr, mode: 'at')
  #
  # warn status unless status.success?
  # next if status.exitstatus == 4 # network failure
  # next if status.exitstatus == 6 # authorization required

  attributes['entries'].push export.attributes

  # Sort entries on something the database can't do:
  # attributes['entries'].sort_by! { |entry| entry['title'] }

  File.open(account.index.to_path, 'wt') do |file|
    file.write(JSON.pretty_generate(attributes))
  end

  # Let others store a archive copy as well.e
  # TODO only allow one submission per month or so.
  Archive.new(export).submit_all
end
