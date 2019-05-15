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
