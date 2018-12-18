require 'fileutils'
require 'json'

# Transmorphs a Pageflow::Revision into attributes we want.
class Export
  include Pageflow::Engine.routes.url_helpers

  attr_reader :entry, :revision

  def initialize(revision)
    @revision = revision
    @entry = Pageflow::PublishedEntry.new(revision.entry, revision)
  end

  def attributes
    {
      locale: locale,
      title: title,
      slug: slug,
      canonical_url: canonical_url,
      publisher: publisher,
      published_at: published_at,
      host: host,
      author: author
    }
  end

  def defaults
    {
      about: {
        name: 'Scrollytelling',
        authors: ['Joost Baaij'],
        email: ['joost@spacebabies.nl'],
        homepage: 'https://www.scrollytelling.com',
        license: "https://creativecommons.org/licenses/by/4.0/"
      },
      account: entry.account.name,
      entries: [],
      export_at: Time.current.iso8601,
      export_format: '1.0.0'
    }
  end

  def locale
    entry.locale
  end

  def title
    entry.title
  end

  def slug
    entry.slug
  end

  def host
    entry.account.default_theming.cname.presence || 'app.scrollytelling.io'
  end

  def canonical_url
    short_entry_url(entry.to_model, host: host, protocol: 'https')
  end

  def publisher
    entry.publisher.presence
  end

  def published_at
    revision.published_at.iso8601
  end

  def author
    author = entry.author.presence
    author unless author == 'Scrollytelling'
  end
end

Pageflow::Revision
  .joins(:entry)
  .published
  .order(:title)
  .each do |revision|

    export = Export.new(revision)
    puts export.canonical_url

    FileUtils.mkdir_p [export.host, export.slug].join('/')
    index = [export.host, 'index.json'].join('/')

    attributes = File.exist?(index) ? JSON.parse(File.read(index)) : export.defaults
    attributes['entries'].push export.attributes

    File.open(index, 'wt') do |file|
      file.write(JSON.pretty_generate(attributes))
    end
end
