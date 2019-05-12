require 'fileutils'
require 'watir'

module Scrollytelling
  module Export
    # Document an entire Scrollytelling by way of screenshots.
    class Screenshot
      attr_reader :story, :browser

      def initialize(story)
        @story = story
        @browser = Watir::Browser.new :chrome,
          headless: true,
          options: { args: ['--window-size=1600,1080'] }
      end

      # Create all screenshots for the Scrollytelling.
      def create_all!
        FileUtils.mkdir_p story.screenshots
        screenshot_story = story.screenshots.join("#{$account.hostname}-#{story.slug}.png")

        if screenshot_story.exist?
          found = Dir.glob(story.screenshots.join('*-page-*.png'))
          found.unshift(screenshot_story.to_s)
          return found
        end

        browser.goto story.url
        browser.execute_script("document.querySelectorAll('.multimedia_alert').forEach(function(item){item.remove()})")

        # Grab all navigable pages.
        nav = browser.nav(id: 'scrollytelling-navigation')
        return unless nav.exists?
        created = []

        puts "#{nav.as.length} screenshots in #{story.screenshots}"
        nav.as.each_with_index do |link, index|
          perma_id = link.href[/#(\d*)\z/, 1]
          filename = [story.slug, 'page', index + 1, "#{perma_id}.png"].join('-')
          next if File.exist?(story.screenshots.join(filename))

          browser.goto link.href
	        sleep 5
          screenshot = browser.screenshot.save(story.screenshots.join(filename))
          created << screenshot.path
          puts "✅ #{screenshot.path}"
        end

        # Grab the opening page; when this exists, all screens are complete.
        browser.goto story.url
        sleep 5
        screenshot = browser.screenshot.save(screenshot_story)
        created.unshift screenshot.path
        puts "✅ #{screenshot.path}"

        created
      rescue Watir::Wait::TimeoutError => error
        warn error.to_s
      end
    end
  end
end
