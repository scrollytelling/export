require 'cgi'
require 'http'

# Submit the page to Internet Archives.
class Archive
  attr_reader :export, :url, :escaped_url

  def initialize(export)
    @export = export
    @url = export.canonical_url
    @escaped_url = CGI::escape(@url)
  end

  def submit_all
    archive_org
    archive_today
  end

  def archive_org
    response = HTTP.get "http://archive.org/wayback/available?url=#{export.host}/#{export.slug}"
    if response.code == 404
      HTTP.get "https://web.archive.org/save/#{url}"
    end
  end

  def archive_today
    HTTP.get "http://archive.today/?run=1&url=#{escaped_url}"
  end
end
