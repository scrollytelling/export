module Scrollytelling
  module Export
    class ExportFile
      attr_reader :file, :attrs

      def initialize(file)
        @file = file

        @attrs = {
          'original_url' => file.url,
          'path' => media(file.url),
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
              {
                'type' => 'application/x-mpegURL',
                'original_url' => file.hls_playlist.url,
                'path' => output(file.hls_playlist.url)
              },
              {
                'type' => 'video/mp4',
                'url' => file.mp4_high.url,
                'path' => output(file.mp4_high.url)
              }
            ]
          if file.poster.present?
            @attrs.merge! \
              'poster_original_url' => file.poster.url,
              'poster_path' => media(file.poster.url)
          end

        when 'Pageflow::AudioFile'
          @attrs.merge! \
            'file_size' => file.attachment_on_s3_file_size,
            'content_type' => file.attachment_on_s3_content_type,
            'duration_in_ms' => file.duration_in_ms,
            'sources' => [
              { 'type' => 'audio/ogg', 'original_url' => file.ogg.url, 'path' => output(file.ogg.url) },
              { 'type' => 'audio/mp4', 'original_url' => file.m4a.url, 'path' => output(file.m4a.url) },
              { 'type' => 'audio/mpeg', 'original_url' => file.mp3.url, 'path' => output(file.mp3.url) }
            ]

        else
          raise "Unknown file: #{file}"
        end

        @attrs
      end

      private

      def media(url)
        return if url.blank?

        url
          .to_s
          .sub(/https:\/\/\/\w+\//, 'media.scrollytelling.com/main/')
      end

      def output(url)
        return if url.blank?

        url
          .to_s
          .sub(/https:\/\/v1\/\w+\/pageflow/, 'output.scrollytelling.com/v1/main/pageflow')
      end
    end
  end
end
