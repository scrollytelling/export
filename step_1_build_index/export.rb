require 'pageflow/engine'

# Transmorphs a Pageflow::Revision into attributes we want.
class Export
  include Pageflow::Engine.routes.url_helpers

  attr_reader :account, :entry, :revision

  def initialize(revision)
    @revision = revision
    @entry = Pageflow::PublishedEntry.new(revision.entry, revision)
    @account = entry.account
  end

  def slug
    entry.slug
  end

  def host
    entry.host
  end

  # Transform ActiveRecord result into array of hashes to export.
  # This is a nested structure, going all the way to this entry's pages.
  def storylines
    revision
      .storylines
      .map do |storyline|
        {
          id: storyline.id,
          position: storyline.position,
          perma_id: storyline.perma_id,
          chapters: chapters(storyline)
        }
      end
  end

  # Straight from Rails path helpers.
  def canonical_url
    short_entry_url(entry.to_model, host: host, protocol: 'https')
  end

  def attributes
    {
      "locale" => entry.locale,
      "title" => entry.title,
      "summary" => revision.summary.presence,
      "host" => host,
      "slug" => entry.slug,
      "canonical_url" => canonical_url,
      "created_at" => revision.entry.created_at.iso8601,
      "updated_at" => revision.entry.updated_at.iso8601,
      "published_at" => revision.published_at.iso8601,
      "publisher" => entry.publisher.presence,
      "author" => author,
      "credits" => revision.credits.presence,
      "storylines" => storylines
    }
  end

  def default_attributes
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

  def manager_names
    account_managers
      .map do |user|
      {
        "first_name" => user.first_name,
        "last_name" => user.last_name
      }
    end
  end

  # Transform ActiveRecord result into array of hashes to export.
  def pages(chapter)
    chapter
      .pages
      .order(:position)
      .map do |page|
        {
          id: page.id,
          position: page.position,
          perma_id: page.perma_id,
          page_type: page.page_type.name,
          configuration: page.configuration,
          template: page.template,
          display_in_navigation: page.display_in_navigation
        }
      end
  end

  # Transform ActiveRecord result into array of hashes to export.
  def chapters(storyline)
    storyline
      .chapters
      .order(:position)
      .map do |chapter|
        {
          id: chapter.id,
          position: chapter.position,
          title: chapter.title,
          pages: pages(chapter)
        }
    end
  end
end
