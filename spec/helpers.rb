require "rubygems" unless RUBY_VERSION =~ /1.9/

require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "rspec"

if RUBY_VERSION =~ /1.9/
  require "simplecov"
  SimpleCov.start
end


require_relative "../lib/pylon"
