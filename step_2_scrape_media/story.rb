# Equally simple wrapper around a story.
Story = Struct.new(:entry) do
  def host
    @host ||= entry['host']
  end

  def slug
    @slug ||= entry['slug']
  end

  def path
    $account.root.join(slug)
  end

  def url
    "https://#{host}/#{slug}"
  end
end
