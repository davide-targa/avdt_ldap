Gem::Specification.new do |s|
  s.name	= 'avdt_ldap'
  s.version	= '0.1.3'
  s.date	= '2011-06-10'
  s.summary	= "Fixed require paths in gemspec"
  s.description = "Simple LDAP authentication library that manages even multiple LDAP servers"
  s.add_runtime_dependency "net-ldap"
  s.authors	= ["Alessandro Verlato", "Davide Targa"]
  s.email	= ["averlato@gmail.com", "davide.targa@gmail.com"]
  s.files	= ["lib/avdt_ldap.rb"]
  s.require_path= "lib"
  s.homepage	= "http://rubygems.org/gems/avdt_ldap"
end
