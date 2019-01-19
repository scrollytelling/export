# Very simple wrapper around a Scrollytelling account.
Account = Struct.new(:host) do
  def root
    Pathname.new("#{__dir__}/../entries/#{host}")
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
  def output_directories!
    FileUtils.mkdir_p(root.join('archive'))
    FileUtils.mkdir_p(root.join('images'))
    FileUtils.mkdir_p(root.join('media.scrollytelling.com'))
    FileUtils.mkdir_p(root.join('output.scrollytelling.com'))
    FileUtils.mkdir_p(root.join('reports'))
    FileUtils.mkdir_p(root.join('scrollytelling.link'))
  end
end
