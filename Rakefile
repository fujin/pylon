# encoding: utf-8

require "rubygems"
require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "rake"
require "rake/testtask"
require "bundler/gem_tasks"

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = "spec/**/*_spec.rb"
  test.verbose = true
end



