# encoding: utf-8

require "rubygems" unless RUBY_VERSION =~ /1.9/
require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "run specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.verbose = true
end

task :default => %w[spec]
