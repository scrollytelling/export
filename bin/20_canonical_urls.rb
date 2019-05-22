#!/usr/bin/env ruby
require_relative 'lib/setup'

account = Scrollytelling::Export::Account.new $cname
puts account.canonical_urls('published_without_password_protection')
