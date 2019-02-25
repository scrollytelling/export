require 'pathname'

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

      # create our desired output structure
      def output_directories!(slug)
        FileUtils.mkdir_p root.join(slug)

        %w[
          archive
          media.scrollytelling.com
          output.scrollytelling.com
          scrollytelling.link

        ].each do |dir|
          FileUtils.mkdir_p root.join(dir)
        end
      end
    end
  end
end
