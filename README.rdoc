= AvdtLdap
[![endorse](http://api.coderwall.com/davidetarga/endorsecount.png)](http://coderwall.com/davidetarga)

This gem supports LDAP authentication both on sigle and multiple LDAP servers with a minimal configuration.
It requires 'net-ldap' gem (automatically installed)

== Installation

=== Rails 3

Add this to your +Gemfile+ and run the +bundle+ command:

  gem "avdt_ldap"

=== Rails 2

Add this to your environment.rb file:

  config.gem "avdt_ldap"

== Usage

Just add a config file named ldap.yml in config/ directory.

You can change default file name by setting +ldap_config_file+ configuration parameter.
For example, inside the avdt_ldap initializer:

  AvdtLdap.configure do |c|
    c.ldap_config_file = "#{Rails.root}/config/foobar.yml"
  end

== ldap.yml

Inside this file you have to specify connection parameters for all the directories on which to verify users credentials

Example file:

  # All the directory attributes (except "base") are optional. Defaults are specified in the example below.

  development:
    dir1:
      host: ldap.foobar.com		# defaults to "127.0.0.1"
      base: ou=People,dc=foobar,dc=com  # REQUIRED
     port: 123				# defaults to 389
      ssl: true				# defaults to false
      attribute: cn			# defaults to "uid"


    dir2:
      host: ldap.goofy.foobar.com
      base: ou=People,dc=goofy,dc=foobar,dc=com

  test:
    dir1:
      host: ldap.test.foobar.com
      base: ou=People,dc=foobar,dc=com

    dir2:
      host: ldap.goofy.foobar.com
      base: ou=People,dc=goofy,dc=foobar,dc=com

  production:
    dir2:
      host: ldap.live.foobar.com
      base: ou=People,dc=foobar,dc=com
      attribute: cn

    new_dir:
      host: donald.duck.com
      attribute: foo
      base: ou=Ducks,dc=foobar,dc=com


Not specified parameters (except for "base" which is required) will be set to the default values:

  host: "127.0.0.1"
  port: 389
  attribute: uid
  base: %s
  ssl: false

== Authentication

To verify user's credentials on ALL the specified directories (default) simply do this:

  AvdtLdap.new.valid?(login, password)

As mentioned this will try to authenticate the user on all the directories specified on ldap.yml and will return true or false.
If authentication fails an error message, containing directory response (error message and code), will be displayed on server's logs.

=== Authentication only on specified directories

If you have to check user's credentials only on some specific directories, you can pass an hash to AvdtLdap.new(), specifying on which to do the check.

  a = AvdtLdap.new(:directories => [:dir1,dir3])
  a.valid?(login,password)
  => true   (false)

NOTE: The authentication process stops as soon as one positive match is found, so it's possible that not all the directories are queried.

=== User's attributes access

If the authentication process is successfull, you can access user's attributes simply calling a method on your AvdtLdap object, with the same name of the desired attribute. For example let's suppose we want the user's name and surname (+givenName+ and +sn+ attributes on the directory), then you can do this:

  username = a.givenname
  surname = a.cn

Note: theese methods must be called on lowercase

You can also access the whole attributes hash by calling:

  a.user_attributes

==== On which directory is located the user ?

You can know it by calling the +user_location+ method on your AvdtLdap object:

  location = a.user_location
