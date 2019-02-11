require 'open3'

module Scrollytelling
  module Export
    class BucketDownloader
      attr_reader :paths

      # expects an array of bucket + paths to grab.
      # It should end with three groups of digits.
      #   e.g. media.scrollytelling.com/main/v1/blah/000/002/432
      def initialize(paths = [])
        @paths = paths
      end

      # Created to parse the 'hosted files' JSON in the editpr.
      def self.file_download(text)
        paths = text
          .scan(/\w*\.scrollytelling\.com.*?\d{3}\/\d{3}\/\d{3}/)
          .sort
          .uniq

        new(paths).sync
      end

      def sync
        paths.each do |path|
          dest = $account.root.join(path)
          from = path.sub(/output\.scrollytelling\.\w+/, 'storyboard-pageflow-production-out')

          stdout, stderr, status = Open3.capture3("aws", "s3", "sync", "s3://#{from}", dest.to_path, "--no-progress")
          if status.success?
            puts "  s3://#{from} ➡️  #{dest}"
          else
            raise [status, stdout, stderr].join("\n")
          end
        end
      end
    end
  end
end
