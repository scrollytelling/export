require 'pathname'

# Very simple wrapper around a Scrollytelling account.
Account = Struct.new(:host) do
  def root
    Pathname.new(__dir__).join('../entries', host)
  end
  def archive_path
    root.join('archive')
  end
  def assets_path
    root.join('scrollytelling.link')
  end
  def output_path
    root.join('output.scrollytelling.com')
  end
  # it's not the indexpage of a story, but index for the entire account.
  def index
    root.join("index.json")
  end
  # create our desired output structure
  def output_directories!(slug)
    FileUtils.mkdir_p archive_path
    FileUtils.mkdir_p root.join('images')
    FileUtils.mkdir_p root.join('media.scrollytelling.com')
    FileUtils.mkdir_p output_path
    FileUtils.mkdir_p root.join('reports')
    FileUtils.mkdir_p assets_path
    FileUtils.mkdir_p root.join(slug)
  end
end
