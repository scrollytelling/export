puts ARGF.read
  .gsub(/<script>\s*window\.PAGEFLOW.*\s*<\/script>\s*/, '')
  .gsub('https://output.scrollytelling.io', '/output.scrollytelling.com')
  .gsub('https://output.scrollytelling.com', '/output.scrollytelling.com')
  .gsub('https://media.scrollytelling.com', '/media.scrollytelling.com')
  .gsub('http://media.scrollytelling.com', '/media.scrollytelling.com')
  .gsub('https://scrollytelling.link', '/scrollytelling.link')
  .gsub(/\?p=.*" data-name/, '" data-name') # ?p=12.2.0&amp;v=pageflow%2Frevisions%2F11502-20170812124810000000000
  .gsub(/^\s*$/, '') # blank lines
  .gsub(' data-turbolinks-track="true"', '')
  .gsub("<head>\n", "<head>\n  <meta charset=\"utf-8\">\n")
  .gsub(/\s*<meta name="csrf.*$/, '')
  .gsub('https://www.scrollytelling.io', 'https://www.scrollytelling.com')
  .gsub(/\.JPG\?\d{10}/, '.JPG')
