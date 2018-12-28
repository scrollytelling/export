require 'json'
require 'pageflow'

require_relative './export'

# Use this script to update all chapters in all indexes.
Dir.glob("../entries/*/index.json").each do |file|
  index = JSON.parse(File.read(file))

  index['entries'].each do |entry|
    record = Pageflow::Entry.find_by_slug! entry['slug']

    export = Export.new(record.published_revision)
    entry['chapters'] = export.chapters
  end

  File.open(file, 'wt') do |file|
    puts JSON.pretty_generate(index)
    # file.write(JSON.pretty_generate(index))
  end
end
