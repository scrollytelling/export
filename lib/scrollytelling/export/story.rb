module Scrollytelling
  module Export
    # Equally simple wrapper around a story.
    Story = Struct.new(:entry) do
      def slug
        @slug ||= entry['slug']
      end

      def path
        $account.root.join(slug)
      end

      def screens
        path.join('screens')
      end

      def url
        "https://#{$account.hostname}/#{slug}"
      end
    end
  end
end
