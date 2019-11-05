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
    end
  end
end
