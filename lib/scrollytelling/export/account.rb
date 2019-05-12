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

      # it's not the indexpage of a story, but index for the entire account.
      def index
        root.join("index.json")
      end

      # Makes a media URL work in the archive.
      # def bucket_path(url)
      #   url
      #     .sub('/media.scrollytelling.io', 'media.scrollytelling.com')
      #     .sub('/output.scrollytelling.io/', '')
      #     .sub(/\?\d{10}\z/, '')
      #     .sub(/\/original.*\z/, '')
      #     .sub(/\/hls-playlist\.m3u8\z/, '')
      #     .sub(/\/high\.mp4\z/, '')
      #     .sub(/\/audio\.\w{3}*\z/, '')
      # end

      def create_root_dirs!
        %w[
          archive
          entries
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
