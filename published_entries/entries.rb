require 'fileutils'
require 'json'

# Transmorphs a Pageflow::Entry into attributes we want.
class Export
  include Pageflow::Engine.routes.url_helpers

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def attributes
    {
      locale: entry.locale,
      title: entry.title,
      host: host,
      slug: entry.slug,
      canonical_url: short_entry_url(entry.to_model, host: host, protocol: 'https'),
      keywords: entry.keywords.presence,
      author: entry.author.presence,
      publisher: entry.publisher.presence,
      published_at: entry.revision.published_at.iso8601
    }
  end

  def host
    entry.account.default_theming.cname.presence || 'app.scrollytelling.io'
  end

  def author
    author = entry.author.presence
    author unless author == 'Scrollytelling'
  end
end

Pageflow::Revision
  .published
  .order(:title)
  .each do |revision|
    next if revision.entry.blank?

    entry = Pageflow::PublishedEntry.new(revision.entry, revision)
    export = Export.new(entry)

    path = "#{export.attributes[:host]}/#{export.attributes[:slug]}"
    puts path
    FileUtils.mkdir_p path

    defaults = { account: entry.account.name, export_at: Time.current.iso8601, export_version: '1.0.0' }
    index = "#{export.attributes[:host]}/index.json"
    json = File.exist?(index) ? File.read(index) : JSON.pretty_generate(defaults)
    attributes = JSON.parse(json)
    attributes['entries'] ||= []
    attributes['entries'].push export.attributes

    File.open(index, 'wt') do |file|
      file.write(JSON.pretty_generate(attributes))
    end
end
