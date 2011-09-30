require "./lib/pylon.rb"

Gem::Specification.new do |s|
  s.name = %q{pylon}
  s.version = Pylon::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["AJ Christensen"]
  s.date = %q{2011-09-19}
  s.default_executable = %q{pylon}
  s.description = %q{leader election with zeromq for ruby using widely available leader election algorithms, similar to gen_leader erlang project in essence}
  s.email = %q{aj@junglist.gen.nz}
  s.executables = ["pylon"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.org"
  ]
  s.files = Dir["lib/**/*.rb"] + Dir["bin/*"] + Dir["cookbooks/**/*"]
  s.homepage = %q{http://github.com/fujin/pylon}
  s.licenses = ["APLv2"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{standalone leader election with zeromq for ruby}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<vagrant>, [">= 0"])
      s.add_development_dependency(%q<virtualbox>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<vagrant>, [">= 0"])
      s.add_development_dependency(%q<virtualbox>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<vagrant>, [">= 0"])
      s.add_development_dependency(%q<virtualbox>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<vagrant>, [">= 0"])
      s.add_development_dependency(%q<virtualbox>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<vagrant>, [">= 0"])
      s.add_development_dependency(%q<virtualbox>, [">= 0"])
      s.add_runtime_dependency(%q<ffi>, ["~> 1.0.9"])
      s.add_runtime_dependency(%q<ffi-rzmq>, ["~> 0.8.2"])
      s.add_runtime_dependency(%q<mixlib-log>, [">= 0"])
      s.add_runtime_dependency(%q<mixlib-cli>, [">= 0"])
      s.add_runtime_dependency(%q<mixlib-config>, [">= 0"])
      s.add_runtime_dependency(%q<uuidtools>, ["~> 2.1.2"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<vagrant>, [">= 0"])
      s.add_development_dependency(%q<virtualbox>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<vagrant>, [">= 0"])
      s.add_dependency(%q<virtualbox>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<vagrant>, [">= 0"])
      s.add_dependency(%q<virtualbox>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<vagrant>, [">= 0"])
      s.add_dependency(%q<virtualbox>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<vagrant>, [">= 0"])
      s.add_dependency(%q<virtualbox>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<vagrant>, [">= 0"])
      s.add_dependency(%q<virtualbox>, [">= 0"])
      s.add_dependency(%q<ffi-rzmq>, ["~> 0.8.2"])
      s.add_dependency(%q<mixlib-log>, [">= 0"])
      s.add_dependency(%q<mixlib-cli>, [">= 0"])
      s.add_dependency(%q<mixlib-config>, [">= 0"])
      s.add_dependency(%q<uuidtools>, ["~> 2.1.2"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 2.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<vagrant>, [">= 0"])
      s.add_dependency(%q<virtualbox>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<vagrant>, [">= 0"])
    s.add_dependency(%q<virtualbox>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 2.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<vagrant>, [">= 0"])
    s.add_dependency(%q<virtualbox>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 2.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<vagrant>, [">= 0"])
    s.add_dependency(%q<virtualbox>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 2.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<vagrant>, [">= 0"])
    s.add_dependency(%q<virtualbox>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 2.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<vagrant>, [">= 0"])
    s.add_dependency(%q<virtualbox>, [">= 0"])
    s.add_dependency(%q<ffi-rzmq>, ["~> 0.8.2"])
    s.add_dependency(%q<mixlib-log>, [">= 0"])
    s.add_dependency(%q<mixlib-cli>, [">= 0"])
    s.add_dependency(%q<mixlib-config>, [">= 0"])
    s.add_dependency(%q<uuidtools>, ["~> 2.1.2"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 2.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<vagrant>, [">= 0"])
    s.add_dependency(%q<virtualbox>, [">= 0"])
  end
end

