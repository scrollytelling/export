require 'fileutils'

Pageflow::Revision.published.each do |revision|
  if (entry = revision.entry)
    host = entry.account.default_theming.cname || 'app.scrollytelling.io'
    FileUtils.mkdir_p "#{host}/#{entry.slug}"
  end
end
