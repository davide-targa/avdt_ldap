class Configuration
  attr_accessor :directories_config_file

  def initialize
    @directories_config_file = "#{Rails.root}/config/ldap.yml"
  end
end