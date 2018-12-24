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
      "locale" => entry.locale,
      "title" => entry.title,
      "summary" => revision.summary.presence,
      "host" => host,
      "slug" => entry.slug,
      "canonical_url" => short_entry_url(entry.to_model, host: host, protocol: 'https'),
      "created_at" => revision.entry.created_at.iso8601,
      "updated_at" => revision.entry.updated_at.iso8601,
      "published_at" => revision.published_at.iso8601,
      "publisher" => entry.publisher.presence,
      "author" => author,
      "credits" => revision.credits.presence,
      "chapters" => chapters(revision.entry.chapters.order(:position))
    }
  end

  def defaults
    manager_names = account_managers.map do |user|
      {
        "first_name" => user.first_name,
        "last_name" => user.last_name
      }
    end

    {
      "info" => {
        "summary" => "A collection of multimedia stories, originally published using Scrollytelling.",
        "created_at" => Time.current.iso8601,
        "format" => '1.0.0',
        "curators" => [
          { "name" => 'Joost Baaij', "email" => 'joost@spacebabies.nl'}
        ],
        "homepage" => 'https://www.scrollytelling.com',
        "repository" => 'https://github.com/scrollytelling/export'
      },
      "entries" => [],
      "account" => {
	      "name" => account.name,
	      "managers" => manager_names,
	      "years_active" => years_active
      },
      "id" => SecureRandom.uuid
    }
  end

  def host
    account.default_theming.cname.presence || 'app.scrollytelling.io'
  end

  def years_active
    @years_active ||= account.entries.pluck('year(created_at)').sort.uniq
  end

  def author
    author = entry.author.presence
    author unless author == 'Scrollytelling'
  end

  def account_managers
    Pageflow::AccountMemberQuery::Scope.new(account)
      .with_role_at_least(:manager)
  end

  private

  # Transform ActiveRecord result into array of hashes.
  def chapters(chapters)
    chapters.map do |chapter|
      {
        position: chapter.position,
        title: chapter.title,
        pages: pages(chapter.pages.order(:position))
      }
    end
  end

  # Transform ActiveRecord result into array of hashes.
  def pages(pages)
    pages.map do |page|
      page
        .attributes
        .slice('title', 'subtitle', 'tagline', 'description', 'text', 'template', 'display_in_navigation')
    end
  end
end

Pageflow::Revision
  .published
  .joins(:entry)
  .order(published_at: :desc)
  .each do |revision|

    export = Export.new(revision)
    puts export.canonical_url

    system("wget " +
      "--adjust-extension " +
      "--convert-links " +
      "--domains=hu.scrollytelling.io,scrollytelling.link " +
      "--https-only " +
      "--mirror " +
      "--output-file=crawler.log " +
      "--page-requisites " +
      "--span-hosts " +
      "--reject robots.txt " +
      "--timestamping " +
      export.canonical_url)

    index = [export.host, 'index.json'].join('/')

    attributes = File.exist?(index) ? JSON.parse(File.read(index)) : export.defaults
    attributes['entries'].push export.attributes

    # Sort entries on something the database can't do:
    # attributes['entries'].sort_by! { |entry| entry['title'] }

    File.open(index, 'wt') do |file|
      file.write(JSON.pretty_generate(attributes))
    end
end
