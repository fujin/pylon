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
require "rake/testtask"
require "bundler/gem_tasks"

desc "run specs"
Rake::TestTask.new do |spec|
  spec.verbose = true
  spec.name = "spec"
  spec.test_files = FileList["spec/**/*_spec.rb"]
  spec.options = "--color --format doc"
end

task :default => %w[spec]
