require 'fileutils'
require 'json'

# Transmorphs a Pageflow::Revision into attributes we want.
class Export
  include Pageflow::Engine.routes.url_helpers

  attr_reader :account, :entry, :revision

  def initialize(revision)
    @revision = revision
    @entry = Pageflow::PublishedEntry.new(revision.entry, revision)
    @account = entry.account
  end

  def attributes
    {
      "locale" => locale,
      "title" => title,
      "summary" => revision.summary.presence,
      "host" => host,
      "slug" => slug,
      "canonical_url" => canonical_url,
      "audio_files" => [],
      "image_files" => [],
      "video_files" => [],
      "created_at" => revision.entry.created_at.iso8601,
      "updated_at" => revision.entry.updated_at.iso8601,
      "published_at" => revision.published_at.iso8601,
      "publisher" => publisher,
      "author" => author,
      "credits" => revision.credits.presence
    }
  end

  def defaults
    {
      "about_this_archive" => {
        "summary" => "Collection of Scrollytelling multimedia stories, converted to static HTML.",
        "authors" => ['Joost Baaij'],
        "emails" => ['joost@spacebabies.nl'],
        "homepage" => 'https://www.scrollytelling.com',
        "repository" => 'https://github.com/scrollytelling/export',
        "license" => "https://creativecommons.org/licenses/by/4.0/",
        "terms" => "License applies to archive data only. Story content: copyright #{account.name} #{years.join(', ')}. All rights reserved."
      },
      "account" => account.name,
      "years" => years,
      "entries" => [],
      "export_at" => Time.current.iso8601,
      "export_format" => '1.0.0'
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
    account.default_theming.cname.presence || 'app.scrollytelling.io'
  end

  def canonical_url
    short_entry_url(entry.to_model, host: host, protocol: 'https')
  end

  def years
    @years ||= account.entries.pluck('year(created_at)').sort.uniq
  end

  def publisher
    entry.publisher.presence
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
    attributes['entries'].sort_by! { |entry| entry['title'] }

    File.open(index, 'wt') do |file|
      file.write(JSON.pretty_generate(attributes))
    end
end
