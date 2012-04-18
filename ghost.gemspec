# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ghost"
  s.version = "0.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bodaniel Jeanes"]
  s.autorequire = "ghost"
  s.date = "2012-04-18"
  s.description = "Allows you to create, list, and modify local hostnames"
  s.email = "me@bjeanes.com"
  s.executables = ["ghost"]
  s.files = ["LICENSE", "README.md", "bin/ghost", "lib/ghost", "lib/ghost/cli.rb", "lib/ghost/host.rb", "lib/ghost/store", "lib/ghost/store/dscl_store.rb", "lib/ghost/store/hosts_file_store.rb", "lib/ghost/store.rb", "lib/ghost/version.rb", "lib/ghost.rb", "spec/ghost", "spec/ghost/cli_spec.rb", "spec/ghost/host_spec.rb", "spec/ghost/store", "spec/ghost/store/dscl_store_spec.rb", "spec/ghost/store/hosts_file_store_spec.rb", "spec/ghost/store_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/bjeanes/ghost"
  s.require_paths = ["lib"]
  s.rubyforge_project = "ghost"
  s.rubygems_version = "1.8.10"
  s.summary = "Allows you to create, list, and modify local hostnames"
  s.test_files = ["spec/ghost", "spec/ghost/cli_spec.rb", "spec/ghost/host_spec.rb", "spec/ghost/store", "spec/ghost/store/dscl_store_spec.rb", "spec/ghost/store/hosts_file_store_spec.rb", "spec/ghost/store_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<optparse-subcommand>, ["= 1.0.0.pre.2"])
      s.add_development_dependency(%q<rspec>, ["= 2.9.0"])
    else
      s.add_dependency(%q<optparse-subcommand>, ["= 1.0.0.pre.2"])
      s.add_dependency(%q<rspec>, ["= 2.9.0"])
    end
  else
    s.add_dependency(%q<optparse-subcommand>, ["= 1.0.0.pre.2"])
    s.add_dependency(%q<rspec>, ["= 2.9.0"])
  end
end
