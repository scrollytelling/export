require 'pathname'
require 'fileutils'

module Scrollytelling
  module Export
    class Account
      attr_reader :home, :hostname

      def initialize(hostname)
        @home = ENV.fetch('HOME')
        @hostname = hostname
      end

      def root
        @root ||= Pathname.new(home).join(hostname)
      end

      def archive_path
        @archive_path ||= root.join('archive')
      end

      def screenshots
        @screenshots ||= archive_path.join('screenshots')
      end

      # it's not the indexpage of a story, but index for the entire account.
      def index
        root.join("index.json")
      end

      # Makes a media URL work in the archive.
      def clean(url)
        url
          .sub('https://output.scrollytelling.io.s3-website.eu-central-1.amazonaws.com', '')
          .sub(/\?\d{10}\z/, '')
          .sub(/\Ahttps:\/\//, '')
          .sub('radion', 'main')
          .sub('/media', 'media')
          .sub('/output', 'output')
          .sub('.io', '.com')
          .sub('.s3-website.eu-central-1.amazonaws.com/radion', '/main')
          .sub(/\/original.*\z/, '')
          .sub(/\/v1.*\z/, '')
      end

      def create_root_dirs!
        %w[
          archive
          media.scrollytelling.com
          output.scrollytelling.com
          scrollytelling.link

        ].each do |dir|
          FileUtils.mkdir_p root.join(dir)
        end
      end

      # create our desired output structure
      def output_directories!(slug)
        FileUtils.mkdir_p root.join(slug)
        create_root_dirs!
      end
    end
  end
end
