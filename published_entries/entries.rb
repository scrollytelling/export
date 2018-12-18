require 'fileutils'
require 'json'

class Story
  include Pageflow::Engine.routes.url_helpers

  attr_reader :story

  def initialize(story)
    @story = story
  end

  def to_h
    host = story.account.default_theming.cname.presence || 'app.scrollytelling.io'

    {
      locale: story.locale,
      title: story.title,
      keywords: story.keywords.presence || Pageflow.config.default_keywords_meta_tag,
      author: story.author.presence || Pageflow.config.default_author_meta_tag,
      publisher: story.publisher.presence || Pageflow.config.default_publisher_meta_tag,
      canonical_url: short_entry_url(story.to_model, host: host, scheme: 'https'),
      published_at: story.revision.published_at.iso8601
    }
  end
end

Pageflow::Revision
  .published
  .order(:title)
  .each do |revision|
    next if revision.entry.blank?

    story = Pageflow::PublishedEntry.new(revision.entry, revision)
    host = story.account.default_theming.cname.presence || 'app.scrollytelling.io'
    puts "#{host}/#{story.slug}"
    FileUtils.mkdir_p "#{host}/#{story.slug}"
    vars_path = "#{host}/index.json"

    json = File.exist?(vars_path) ? File.read(vars_path) : '{}'
    vars = JSON.parse(json)
    vars['account'] ||= story.account.name
    vars['entries'] ||= []

    vars['entries'].push Story.new(story).to_h

    File.open(vars_path, 'wt') do |file|
      file.write(JSON.pretty_generate(vars))
    end
end
