class Configuration
  attr_accessor :ldap_config_file

  def initialize
    @ldap_config_file = "#{Rails.root}/config/ldap.yml"
  end
end
