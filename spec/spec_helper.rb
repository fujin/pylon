require "rspec/autorun"
require "rspec/mocks"

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift(File.expand_path("../lib", __FILE__))
$:.unshift(File.dirname(__FILE__))

Dir[File.join(File.dirname(__FILE__), "..", "lib", "**", "*.rb")].sort.each { |lib| require lib }
