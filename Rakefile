# encoding: utf-8

require "rubygems" unless RUBY_VERSION =~ /1.9/
require "bundler"
begin
  Bundler.setup(:default,
                :development,
                :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end


require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/testtask"

RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.rspec_opts = "--color --format doc"
end

task :default => %w[spec]
