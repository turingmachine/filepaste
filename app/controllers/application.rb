# Copyright (C) 2008 Andreas Zuber 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'net/ldap'

class ApplicationController < ActionController::Base
  before_filter :load_settings, :authenticate

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '87756b121176328abb8c413a7674af31'
  
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
