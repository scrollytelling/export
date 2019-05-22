$cname = ARGV[0]
if $cname.nil?
  abort <<~USAGE
    Usage: #{$0} <cname you wish to export>
      e.g: #{$0} stories.example.com
    USAGE
end

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
