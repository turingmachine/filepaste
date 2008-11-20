# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'net/ldap'

class ApplicationController < ActionController::Base
  before_filter :load_settings, :authenticate

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '87756b121176328abb8c413a7674af31'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def load_settings
    @filepaste_settings = YAML.load( File.open( RAILS_ROOT + "/config/settings.yml" ) )
  end

  def authenticate
    authenticate_or_request_with_http_basic @filepaste_settings['general']['title'] do |username, password|
      ldap = Net::LDAP.new  :host => @filepaste_settings['ldap']['host'],
                            :base => @filepaste_settings['ldap']['base'],
                            :port => @filepaste_settings['ldap']['port']

      # Search for the DN of the Username
      username_with_dn = ""
      filter = Net::LDAP::Filter.eq( 'uid', username )
      ldap.search( :filter => filter ) { |entry| username_with_dn = entry.dn }
      ldap.auth username_with_dn, password
      
      # Lest have a look if the user is in the admin group
      admin_filter = Net::LDAP::Filter.eq( 'memberUid', username )
      session[:admin_group] = false
      ldap.search :filter => admin_filter,
                  :base => @filepaste_settings['ldap']['admin_group_dn'] do |entry|
                    session[:admin_group] = true
                  end

      ldap.bind
    end
  end

end
