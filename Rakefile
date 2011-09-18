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
require "jeweler"
require "rake/testtask"
require "bundler/gem_tasks"
require_relative "lib/pylon"

Jeweler::Tasks.new do |gem|
  gem.name = "pylon"
  gem.homepage = "http://github.com/fujin/pylon"
  gem.license = "APLv2"
  gem.summary = %Q{standalone leader election with zeromq for ruby}
  gem.description = %Q{leader election with zeromq for ruby using widely available leader election algorithms, similar to gen_leader erlang project in essence}
  gem.email = "aj@junglist.gen.nz"
  gem.authors = ["AJ Christensen"]
  gem.version = Pylon::VERSION
  { "ffi-rzmq" => "~> 0.8.2",
    "mixlib-log" => ">= 0",
    "mixlib-cli" => ">= 0",
    "mixlib-config" => ">= 0",
    "uuidtools" => "~> 2.1.2",
    "json" => ">= 0"
  }.each { |dep,ver| gem.add_runtime_dependency dep, ver }
  { "minitest" => "~> 2.6.0",
    "bundler" => "~> 1.0.0",
    "jeweler" => "~> 1.6.4",
    "rcov" => ">= 0",
    "vagrant" => ">= 0",
    "virtualbox" => ">= 0"
  }.each { |dep,ver| gem.add_development_dependency dep, ver }
end

Jeweler::RubygemsDotOrgTasks.new

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end



