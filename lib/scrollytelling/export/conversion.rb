require 'active_support'
require 'active_support/core_ext/object/blank'

module Scrollytelling
  module Export
    # Converts URLs to paths.
    # This class has to be initialized with a mediafile, i.e. ImageFile, etc.
    class Conversion
      # Converts a media URL into the path we use in the archive.
      def media_archive_path(url)
        url
          .to_s
          .sub(/https:\/\/\/\w+\//, '/media.scrollytelling.com/main/')
      end

      # Converts a media URL into the path we use in the archive.
      def output_archive_path
        return if file.url.blank?

        file
          .url
          .sub(/https:\/\/v1\/pageflow/, '/output.scrollytelling.com/v1/main/pageflow')
      end

    end
  end
end
