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
      { "bundler" => "~> 1.0.0",
        "jeweler" => "~> 1.6.4",
        "simplecov" => ">= 0",
        "vagrant" => ">= 0",
        "virtualbox" => ">= 0",
        "rspec" => "~> 2.8.0",
        "guard" => "~> 0.10.0",
        "guard-rspec" => "~> 0.6.0",
        "libnotify" => "~> 0.7.2"
      }.each do |gem, version|
        s.add_development_dependency(gem, [version])
      end

      { "ffi" => "~> 1.0.9",
        "ffi-rzmq" => "~> 0.8.2",
        "mixlib-log" => ">= 0",
        "mixlib-cli" => ">= 0",
        "mixlib-config" => ">= 0",
        "uuidtools" => "~> 2.1.2",
        "json" => ">= 0"
      }.each do |gem, version|
        s.add_runtime_dependency(gem, [version])
      end
    end
  end
end
