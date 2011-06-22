# AvdtLdap

# This gem supports LDAP authentication both on sigle and multiple servers
# with a minimal configuration.
# It requires 'net/ldap' gem.
# 
# USAGE
# Single directory authentication:
# Autentication attempt will be made on environment-specific directory (i.e "development")
# 
# AvdtLdap.new.valid?(login, password)
# => true (false)
#
# Multiple directories authentication:
# Here we have authentication attemps made on 2 directories: the "foobar" and
# the default (i.e environment-specific one)
#
#  a = AvdtLdap.new(:directories => [:foobar], :include_default => true)
#  a.valid?(login,password)
#  => true (false)
#
# User's attributes access:
# If you have to access (read) user's attributes from the directory you can
# use the handy methods provided by the gem. Let's suppose we need two attributes,
# the user's name and surname ("givenName" and "sn" attributes on the directory).
# Simply access attributes as in the example below:
#
# a = AvdtLdap.new.valid?(login, password)
# name = a.givenname
# surname = a.cn
#
# As you can see methods names reflects attribute's name (but always in downcase).
# You can also access the whole attributes hash by calling:

# a.user_attributes
#
# On which directory is located the user ?
# You can know it by calling the +user_location+ method on your AvdtLdap object:
#
# location = a.user_location

require 'net/ldap'

class AvdtLdap

  # Used to simplify configuration from rails initializers.
  # Works with the methods configuration and configure defined below.
  class << self
    attr_accessor :configuration
  end

  attr_accessor :directories, :include_default, :user_attributes, :user_location

  # Loads ldap configuration file and sets up the object's parameters
  def initialize(args = {})
    if File.exist?(AvdtLdap.configuration.ldap_config_file)
      @LDAP = YAML.load_file(AvdtLdap.configuration.ldap_config_file).symbolize_keys!
    else
      raise "AvdtLdap: File #{AvdtLdap.configuration.ldap_config_file} not found, maybe you forgot to define it ?"
    end
    @directories = args[:directories] || @LDAP[env].keys
  end

  # Checks for user's existance on specified directories. Just pass "login" and
  # "password" parameters to chech if a user resides on one of the directories.
  # After this method calling, if the user is authenticated, his (directory)
  # attributes are availaible.
  def valid? login, password
    @directories.each do |ldap|
      ldap = ldap.to_sym
      unless @LDAP[env][ldap].nil?
        conn = connection(ldap)
        conn.authenticate("#{attribute(ldap)}=#{login.to_s},#{base(ldap)}", password.to_s)
        begin
          # if bind => OK
          if conn.bind
            logger.info("Authenticated #{login.to_s} by #{host(ldap)}") if logger
            @user_attributes = conn.search(:base => base(ldap),:filter => Net::LDAP::Filter.eq(attribute(ldap),login.to_s)).first.each do |k,v|
              class_eval "attr_reader :#{k}"
              self.instance_variable_set "@#{k}".to_sym, v
            end
            @user_location = ldap
            return true
          else
            logger.info("Error attempting to authenticate #{login.to_s} by #{host(ldap)}: #{conn.get_operation_result.code} #{conn.get_operation_result.message}") if logger
          end
        rescue Net::LDAP::LdapError => error
          logger.info("Error attempting to authenticate #{login.to_s} by #{host(ldap)}: #{error.message}") if logger
          return false
        end
      else
        logger.info "ERROR ! \"#{ldap}\" directory data are missing in ldap.yml" if logger
        raise Net::LDAP::LdapError, "\"#{ldap}\" directory data are missing in ldap.yml"
      end
    end
    false
  end

  # Adds configuration ability to the gem
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  private

  # Given a directory name returns a connection to that server using parameters
  # specified in ldap.yml
  def connection(which_ldap)
    Net::LDAP.new(:host => host(which_ldap), :port => port(which_ldap), :encryption => (:simple_tls if ssl?(which_ldap)))
  end

  # Given a directory return it's host name
  def host(which_ldap)
    @LDAP[env][which_ldap][:host] || "127.0.0.1"
  end

  # Given a directory returns it's host port
  def port(which_ldap)
    ssl?(which_ldap) ? (@LDAP[env][which_ldap][:port] || 636) : (@LDAP[env][which_ldap][:port] || 389)
  end

  # Given a directory returns it's attribute (example: uid)
  def attribute(which_ldap)
    @LDAP[env][which_ldap][:attribute] || "uid"
  end

  # Given a directory returns it's base path (example ou=People,dc=foo,dc=bar)
  def base(which_ldap)
    @LDAP[env][which_ldap][:base] || "%s"
  end

  # Given a directory returns if connection should use ssl
  def ssl?(which_ldap)
    @LDAP[env][which_ldap][:ssl] ? true : false
  end

  # Returns Rails Default logger
  def logger
    Rails.logger
  end

  def env
    Rails.env.to_sym
  end

end
