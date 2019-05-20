require 'fileutils'
require 'watir'

module Scrollytelling
  module Export
    # Document an entire Scrollytelling by way of screenshots.
    class Screenshot
      attr_accessor :paths
      attr_reader :story, :browser

      def initialize(story)
        @story = story
        @browser = Watir::Browser.new :chrome,
          headless: true,
          options: { args: ['--window-size=1600,1080'] }
        @paths = { title_card: absolute(title_card_path), pages: [] }
      end

      def title_card_path
        story.screenshots.join("#{$account.hostname}-#{story.slug}.png")
      end

      def absolute(path)
        elements = path.to_s.split('/')
        elements.shift(4)
        elements.unshift('')
        elements.join('/')
      end

      # Create all screenshots for the Scrollytelling.
      def create_all!
        if title_card_path.exist?
          Dir
            .glob(story.screenshots.join("*page*.png"))
            .sort_by { |path| path.scan(/\d+/).first.to_i }
            .each do |path|

            @paths[:pages] << absolute(path)
          end
          return
        end

        FileUtils.mkdir_p story.screenshots

        browser.goto story.url
        browser.execute_script("document.querySelectorAll('.multimedia_alert').forEach(function(item){item.remove()})")

        # Grab all navigable pages.
        nav = browser.nav(id: 'scrollytelling-navigation')
        return unless nav.exists?

        puts "#{nav.as.length} screenshots in #{story.screenshots}"
        nav.as.each_with_index do |link, index|
          perma_id = link.href[/#(\d*)\z/, 1]
          filename = [story.slug, 'page', index + 1, "#{perma_id}.png"].join('-')
          next if File.exist?(story.screenshots.join(filename))

          browser.goto link.href
          sleep 5
          screenshot = browser.screenshot.save(story.screenshots.join(filename))
          @paths[:pages] << absolute(screenshot.path)
          puts "✅ #{screenshot.path}"
        end

        # Grab the opening page; when this exists, all screens are complete.
        browser.goto story.url
        sleep 5
        screenshot = browser.screenshot.save(title_card_path)
        @paths[:title] = absolute(screenshot.path)
        puts "✅ #{screenshot.path}"
      rescue Watir::Wait::TimeoutError => error
        warn error.to_s
      end
    end
  end
end
