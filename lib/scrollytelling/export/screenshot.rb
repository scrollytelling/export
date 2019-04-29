require 'fileutils'
require 'watir'
require 'vips'

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
        FileUtils.mkdir_p story.screens
        if File.exist?(story.screens.join("#{$account.hostname}-#{story.slug}.jpg"))
          return Dir.glob(story.screens.join('*.jpg'))
        end

        browser.goto story.url
        browser.wait_until { |b| b.body.class_name.include? 'finished-loading' }
        browser.execute_script("document.querySelectorAll('.multimedia_alert').forEach(function(item){item.remove()})")

        # Grab the opening page
        browser.screenshot.save story.screens.join("#{$account.hostname}-#{story.slug}.png")

        # Grab all navigable pages.
        nav = browser.nav(id: 'scrollytelling-navigation')
        return unless nav.exists?

        print "Attempting #{nav.as.length} screenshots in #{story.screens}: "
        nav.as.each_with_index do |link, index|
          browser.goto "#{story.url}#{link.href}"
          uri = URI(browser.url)

          browser.section(id: uri.fragment).wait_until { |s| s.class_name.include? 'active' }
          browser.screenshot.save story.screens.join("#{story.slug}-page#{index + 1}_#{uri.fragment}.png")
          print "#{index+1} "
        end

        puts

        filenames = []
        cap = browser.driver.capabilities

        Dir.glob(story.screens.join('*.png')).each do |filename|
          image = Vips::Image.new_from_file(filename)

          image.set_type GObject::GSTR_TYPE,
            'exif-ifd0-XPTitle', story.entry['title']
          image.set_type GObject::GSTR_TYPE,
            'exif-ifd0-XPComment', story.url
          image.set_type GObject::GSTR_TYPE,
            'exif-ifd0-ImageDescription', "You're seeing a screenshot of the online story #{story.entry['title']}. It was made using a scripted Chrome browser in the process of archiving the full story."
          image.set_type GObject::GSTR_TYPE,
            'exif-ifd0-XPKeywords', %w(scrollytelling pageflow Screenshots).join(',')
          image.set_type GObject::GSTR_TYPE,
            'exif-ifd0-Software', [cap.browser_name, cap.version, cap.platform].join('/')
          image.set_type GObject::GSTR_TYPE,
            'exif-ifd0-Copyright', 'CC-BY-4.0'

          options = { Q: 85, interlace: true, optimize_coding: true }
          image.jpegsave filename.sub('.png', '.jpg'), options
          filenames << image.filename

          thumbnail = image.thumbnail_image 280
          thumbnail.jpegsave filename.sub('.png', '_280.jpg'), options.merge(strip: true)

          # command line:
          # ls **/screens/*.png | xargs vipsthumbnail --size=280 --output='%s_280.jpg[Q=85,optimize_coding,interlace]' --delete --rotate

        end

        filenames
      rescue Watir::Wait::TimeoutError => error
        warn error.to_s
      end
    end
  end
end
