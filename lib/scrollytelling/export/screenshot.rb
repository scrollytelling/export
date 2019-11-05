require 'fileutils'
require 'ferrum'

module Scrollytelling
  module Export
    # Document an entire Scrollytelling by way of screenshots.
    class Screenshot
      attr_accessor :paths
      attr_reader :story, :browser

      def initialize(story)
        @story = story
        @browser = Ferrum::Browser.new(
          timeout: 60,
          window_size: [1600,1080]
        )
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
        browser.add_script_tag content: <<~JS
          pageflow.ready.then(function() {
            $('.multimedia_alert').remove()
          })
        JS


        # Grab all navigable pages.
        browser.goto story.url
        pages = browser.css('#scrollytelling-navigation a')
        puts "#{pages.length} screenshots in #{story.screenshots}"

        pages.each_with_index do |link, index|
          perma_id = link.attribute('href')[/#(\d*)\z/, 1]
          url = [story.url, link.attribute('href')].join
          filename = [story.slug, 'page', index + 1, "#{perma_id}.png"].join('-')
          next if File.exist?(story.screenshots.join(filename))

          print "#{url}... "
          browser.goto url
          sleep 2 if index == 0

          until browser.at_css('body').attribute('class').include? 'finished-loading'
            sleep 0.1
          end

          browser.screenshot(path: story.screenshots.join(filename))
          @paths[:pages] << absolute(story.screenshots.join(filename))
          puts "✅ #{filename}"
        end

        # Grab the opening page; when this exists, all screens are complete.
        browser.goto story.url
        sleep 2
        browser.screenshot(full: true, path: title_card_path)
        @paths[:title] = absolute(title_card_path)

        browser.quit
      end
    end
  end
end
