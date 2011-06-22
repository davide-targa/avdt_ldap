# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "avdt_ldap/version"

Gem::Specification.new do |s|
  s.name        = "avdt_ldap"
  s.version     = AvdtLdap::VERSION
  s.authors     = ["Alessandro Verlato","Davide Targa"]
  s.email       = ["averlato@gmail.com","davide.targa@gmail.com"]
  s.homepage    = "https://rubygems.org/gems/avdt_ldap"
  s.summary     = %q{Simple LDAP authentication library for user authentication on multiple LDAP directories}
  s.description = %q{This gem can manage user authentication on multiple LDAP directories that can reside either on same server or not.}

  s.rubyforge_project = "avdt_ldap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "net-ldap"
end
