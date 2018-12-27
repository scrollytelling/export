require 'fileutils'
require 'watir'
require 'vips'

# Document an entire Scrollytelling by way of screenshots.
class Screenshot
  attr_reader :story, :browser

  def initialize(story)
    @story = story
    @browser = Watir::Browser.new :chrome,
      headless: true,
      options: { args: ['--window-size=1600,1080'] }
  end

  def path
    story.path.join('screens')
  end

  # Create all screenshots for the Scrollytelling.
  def create_all!
    puts "Grabbing screenshots for #{story.entry['title']}"
    puts "Output folder: #{path}"
    puts

    FileUtils.rmtree path
    FileUtils.mkdir_p path

    browser.goto story.url
    browser.wait_until { |b| b.body.class_name.include? 'finished-loading' }
    browser.execute_script("document.querySelectorAll('.multimedia_alert').forEach(function(item){item.remove()})")

    # Grab the opening page
    browser.screenshot.save path.join("#{story.host}-#{story.slug}.png")

    # Grab all navigable pages.
    nav = browser.nav(id: 'scrollytelling-navigation')
    return unless nav.exists?

    nav.as.each_with_index do |link, index|
      browser.goto link.attribute_value('href')
      uri = URI(browser.url)

      browser.section(id: uri.fragment).wait_until { |s| s.class_name.include? 'active' }
      screenshot = path.join("#{story.slug}-page#{index + 1}_#{uri.fragment}.png")
      browser.screenshot.save screenshot

      screenshot = screenshot.realpath.to_s
      image = Vips::Image.new_from_file(screenshot)

      image.set_type GObject::GSTR_TYPE,
        'exif-ifd0-XPTitle', story.entry['title']
      image.set_type GObject::GSTR_TYPE,
        'exif-ifd0-XPComment', link.to_s
      image.set_type GObject::GSTR_TYPE,
        'exif-ifd0-ImageDescription', "#{story.entry['title']} page #{index + 1}"
      image.set_type GObject::GSTR_TYPE,
        'exif-ifd0-XPKeywords', %w(scrollytelling pageflow screenshot).join(',')
      cap = browser.driver.capabilities
      image.set_type GObject::GSTR_TYPE,
        'exif-ifd0-Software', [cap.browser_name, cap.version, cap.platform].join('/')

      options = { Q: 85, interlace: true, optimize_coding: true }
      jpeg = screenshot.sub('.png', '.jpg')
      image.jpegsave jpeg, options

      thumbnail = image.thumbnail_image 280
      thumbnail.jpegsave jpeg.sub('.jpg', '_280.jpg'), options.merge(strip: true)

    rescue Watir::Wait::TimeoutError => error
      warn error.to_s
      next
    end
  end
end
