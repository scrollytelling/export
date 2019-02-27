require 'pageflow/engine'

module Scrollytelling
  module Export
    # Transmorphs a Pageflow::Revision into attributes we want.
    class Export
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
            "format" => '1.0.0',
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
        @audio_files ||= find_files(Pageflow::AudioFile)
      end

      def video_files
        @video_files ||= find_files(Pageflow::VideoFile)
      end

      def image_files
        @image_files ||= find_files(
          Pageflow::ImageFile
            .where(unprocessed_attachment_content_type: ['image/jpeg', 'image/png'])
        )
      end

      private

      class ExportFile
        attr_reader :file, :attrs

        def initialize(file)
          @file = file

          @attrs = {
            'original_url' => file.url,
            'path' => exported_url(file.url),
            'rights' => file.rights
          }
        end

        def attributes
          case file.class.to_s
          when 'Pageflow::ImageFile'
            @attrs.merge! \
              'file_size' => file.unprocessed_attachment_file_size,
              'content_type' => file.unprocessed_attachment_content_type,
              'width' => file.width,
              'height' => file.height

          when 'Pageflow::VideoFile'
            @attrs.merge! \
              'file_size' => file.attachment_on_s3_file_size,
              'content_type' => file.attachment_on_s3_content_type,
              'width' => file.width,
              'height' => file.height,
              'duration_in_ms' => file.duration_in_ms,
              'sources' => [
                { 'type' => 'application/x-mpegURL', 'original_url' => file.hls_playlist.url, 'path' => exported_url(file.hls_playlist.url) },
                { 'type' => 'video/mp4', 'url' => file.mp4_high.url, 'path' => exported_url(file.mp4_high.url) }
              ]
            if file.poster.present?
              @attrs.merge! \
                'poster_original_url' => file.poster.url,
                'poster_path' => exported_url(file.poster.url)
            end

          when 'Pageflow::AudioFile'
            @attrs.merge! \
              'file_size' => file.attachment_on_s3_file_size,
              'content_type' => file.attachment_on_s3_content_type,
              'duration_in_ms' => file.duration_in_ms,
              'sources' => [
                { 'type' => 'audio/ogg', 'original_url' => file.ogg.url, 'path' => exported_url(file.ogg.url) },
                { 'type' => 'audio/mp4', 'original_url' => file.m4a.url, 'path' => exported_url(file.m4a.url) },
                { 'type' => 'audio/mpeg', 'original_url' => file.mp3.url, 'path' => exported_url(file.mp3.url) }
              ]

          else
            raise "Unknown file: #{file}"
          end

          @attrs
        end

        private

        def exported_url(url)
          warn "#{file.attributes} has nil url" and return if url.blank?

          url
            .sub('https:///djax', '/output.scrollytelling.com')
            .sub(/\?\d{10}\z/, '')
        end
      end

      # https://github.com/codevise/pageflow/blob/f0342d71ac80d2f2b67f9a6a666706d7333f0ba7/app/models/pageflow/revision.rb#L134
      def find_files(model, extra: [])
        model
          .includes(:usages)
          .references(:pageflow_file_usages)
          .where(pageflow_file_usages: {revision_id: revision.id})
          .map do |file|
            ExportFile.new(file).attributes
          end
      end

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
