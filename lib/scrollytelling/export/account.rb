require 'pathname'
require 'fileutils'
require 'json'

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

      # Array of URLs, optionally filtered on publication_state.
      def canonical_urls(publication_state = nil)
        archive = JSON.parse(index.read)
        archive['entries'].map do |entry|
          entry['canonical_url'] if publication_state && entry['publication_state'] == publication_state
        end.compact
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
