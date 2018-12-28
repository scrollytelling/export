require 'fileutils'
require 'json'
require 'open3'
require 'http'

require_relative './archive'
require_relative './export'

revisions = Pageflow::Revision
  .published
  .joins(:entry)
  .includes(entry: [:account], storylines: { chapters: [:pages] })
  .order(published_at: :desc)

revisions.each_with_index do |revision, counter|
  export = Export.new(revision)
  dir = Pathname.new(__dir__).join('../entries')
  index = dir.join(export.host, 'index.json')
  FileUtils.mkdir_p(index.dirname)

  if index.exist?
    index_text = index.read
    # if the index already has our story, skip.
    next if index_text.include?(export.entry.slug)
    attributes = JSON.parse(index_text)
  else
    attributes = export.default_attributes
  end

  puts "[#{counter + 1}/#{revisions.length}] #{export.canonical_url}"

  # Let others store a archive copy as well.e
  # TODO only allow one submission per month or so.
  Archive.new(export).submit_all

  stdout, stderr, status = Open3.capture3("wget",
    "--adjust-extension",
    "--convert-links",
    "--domains=#{export.host},scrollytelling.link",
    "--https-only",
    "--mirror",
    "--page-requisites",
    "--reject=audio,index.html,robots.txt,videos",
    "--span-hosts",
    "--timestamping",
    export.canonical_url, chdir: dir
  )

  dir.join('reports', 'crawler.out.log').write(stdout.read, 'at')
  dir.join('reports', 'crawler.err.log').write(stderr.read, 'at')

  warn status unless status.success?
  next if status.exitstatus == 4 # network failure
  next if status.exitstatus == 6 # authorization required

  attributes['entries'].push export.attributes

  # Sort entries on something the database can't do:
  # attributes['entries'].sort_by! { |entry| entry['title'] }

  File.open(index.to_path, 'wt') do |file|
    file.write(JSON.pretty_generate(attributes))
  end
end
