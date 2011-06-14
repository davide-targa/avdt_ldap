# AvdtLdap

# This gem supports LDAP authentication both on sigle and multiple servers
# with a minimal configuration.
# It requires 'net/ldap' gem.
# 
# USAGE
# Single directory authentication
# Autentication attempt will be made on environment-specific directory (i.e "development")
# 
# AvdtLdap.new.valid?(login, password)
# => true (false)
#
# Multiple directories authentication
# Here we have authentication attemps made on 2 directories: the "foobar" and
# the default (i.e environment-specific one)
#
#  a = AvdtLdap.new(:directories => [:foobar], :include_default => true)
#  a.valid?(login,password)
#  => true (false)



require 'net/ldap'
require 'configuration'

class AvdtLdap

  class << self
    attr_accessor :configuration
  end

  attr_accessor :directories, :include_default, :user_attributes
  #attr_accessor :configuration

  def initialize(args = {})
    if File.exist?(AvdtLdap.configuration.ldap_config_file)
      @LDAP = YAML.load_file(AvdtLdap.configuration.ldap_config_file).symbolize_keys
    else
      raise "AvdtLdap: File #{AvdtLdap.configuration.ldap_config_file} not found, maybe you forgot to define it ?"
    end
    @directories = args[:directories] || []
    @directories << Rails.env if ((@directories.any? and args[:include_default]) or !@directories.any?)
  end

  
  def valid? login, password
    @directories.each do |ldap|
      ldap = ldap.to_s
      unless @LDAP[ldap].nil?
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
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  private

  def connection(which_ldap)
    Net::LDAP.new(:host => host(which_ldap), :port => port(which_ldap), :encryption => (:simple_tls if ssl?(which_ldap)))
  end

  def host(which_ldap)
    @LDAP[which_ldap][:host] || "127.0.0.1"
  end

  def port(which_ldap)
    ssl?(which_ldap) ? (@LDAP[which_ldap][:port] || 636) : (@LDAP[which_ldap][:port] || 389)
  end

  def attribute(which_ldap)
    @LDAP[which_ldap][:attribute] || "uid"
  end

  def base(which_ldap)
    @LDAP[which_ldap][:base] || "%s"
  end

  def ssl?(which_ldap)
    @LDAP[which_ldap][:ssl] ? true : false
  end

  def logger
    Rails.logger
  end

end
