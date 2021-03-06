module Scrollytelling
  module Export
    # Equally simple wrapper around a story.
    Story = Struct.new(:entry) do
      def slug
        entry['slug']
      end

      def title
        entry['title']
      end

      def caption
        entry['summary']
      end

      def path
        $account.root.join(slug)
      end

      def screenshots
        path.join('screenshots')
      end

      def url
        entry['canonical_url']
      end

      def keywords
        entry['keywords']
      end

      def language
        entry['locale']
      end

      def published_at
        entry['published_at']
      end
    end
  end
end
