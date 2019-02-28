#!/usr/bin/env ruby
# This is the Ruby part of the export pipeline.

hostname = ARGV[0]
abort "Missing argument: cname of the account to export." if hostname.nil?


$account = Account.new hostname

export = Scrollytelling::Export.new ARGV[0]
index = Scrollytelling::Export::Index.new export
