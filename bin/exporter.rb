# This is the Ruby part of the export pipeline.

$account = Account.new ENV.fetch('ACCOUNT', 'stories.scrollytelling.com')

export = Scrollytelling::Export.new ARGV[0]
index = Scrollytelling::Export::Index.new export
