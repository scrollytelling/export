require 'pageflow/engine'

require_relative './exportfile'

module Scrollytelling
  module Export
    # Transmorphs a Pageflow::Revision into attributes we want.
    class Exporter
      include Pageflow::Engine.routes.url_helpers

      attr_reader :account, :entry, :revision, :slug

      def initialize(revision)
        @revision = revision
        @entry = Pageflow::PublishedEntry.new(revision.entry, revision)
        @account = @entry.account
        @slug = @entry.slug
      end

      def hostname
        account.default_theming.cname.presence || 'app.scrollytelling.io'
      end

      # Straight from Rails path helpers.
      def canonical_url
        short_entry_url(entry.to_model, host: hostname, protocol: 'https')
      end

      def entry_attributes
        {
          "locale" => entry.locale,
          "title" => entry.title,
          "summary" => revision.summary.presence,
          "slug" => slug,
          "canonical_url" => canonical_url,
          "created_at" => revision.entry.created_at.iso8601,
          "updated_at" => revision.entry.updated_at.iso8601,
          "published_at" => revision.published_at.iso8601,
          "publisher" => entry.publisher.presence,
          "author" => author,
          "credits" => revision.credits.presence,
          "storylines" => storylines,
          "audio_files" => audio_files,
          "video_files" => video_files,
          "image_files" => image_files
        }
      end

      def account_attributes
        {
          "account" => {
            "name" => account.name,
            "hostname" => hostname,
            "managers" => manager_names,
            "years_active" => account.entries.order(:created_at).pluck('year(created_at)').uniq
          },
          "archive" => {
            "id" => SecureRandom.uuid,
            "summary" => "A collection of multimedia stories, originally published using Scrollytelling.",
            "created_at" => Time.current.iso8601,
            "format" => '1.1.0',
            "curators" => [
              { "name" => 'Joost Baaij', "email" => 'joost@spacebabies.nl'}
            ],
            "homepage" => 'https://www.scrollytelling.com',
            "repository" => 'https://github.com/scrollytelling/export'
          },
          "entries" => [
            entry_attributes
          ]
        }
      end

      def author
        author = entry.author.presence
        author unless author == 'Scrollytelling'
      end

      def account_managers
        Pageflow::AccountMemberQuery::Scope.new(account)
          .with_role_at_least(:manager)
      end

      def audio_files
        @audio_files ||= revision.audio_files.map do |file|
          Scrollytelling::Export::ExportFile.new(file).attributes
        end
      end

      def video_files
        @video_files ||= revision.video_files.map do |file|
          Scrollytelling::Export::ExportFile.new(file).attributes
        end
      end

      def image_files
        @image_files ||= revision.image_files.map do |file|
          Scrollytelling::Export::ExportFile.new(file).attributes
        end
      end

      private

      # Transform ActiveRecord result into array of hashes to export.
      # This is a nested structure, going all the way to this entry's pages.
      def storylines
        revision
          .storylines
          .map do |storyline|
            {
              'position' => storyline.position,
              'perma_id' => storyline.perma_id,
              'chapters' => chapters(storyline)
            }
          end
      end

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
              'position' => page.position,
              'perma_id' => page.perma_id,
              'page_type' => page.page_type.name,
              'configuration' => page.configuration
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
              'position' => chapter.position,
              'title' => chapter.title,
              'pages' => pages(chapter)
            }
          end
      end
    end
  end
end
