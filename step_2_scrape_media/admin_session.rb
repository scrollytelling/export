require 'watir'

# Pretend to be a Scrollytelling administrator.
class AdminSession
  attr_accessor :browser

  def initialize
    @browser = Watir::Browser.new :chrome,
      headless: true,
      options: { args: ['--window-size=1600,1080'] }
  end

  def login
    browser.goto 'https://app.scrollytelling.io/admin/login'
    browser.text_field(label: 'Email*').set ENV.fetch('EMAIL', 'joost@spacebabies.nl')
    browser.text_field(label: 'Password*').set ENV.fetch('PASSWORD')
    browser.button(value: 'Login').click
  end

  # Returns a JSON string with all hosted files for the given story and type.
  def hosted_files(slug, filetype)
    browser.goto "https://app.scrollytelling.io/editor/entries/#{slug}/files/#{filetype}.json"
    browser.text
  end
end
