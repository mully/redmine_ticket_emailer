# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Ticket Emailer Plugin'

# Redmine ticket emailer plugin
Redmine::Plugin.register :ticket_emailer do
  name 'Ticket Emailer'
  author 'Jim Mulholland'
  description 'A plugin to allow users to email tickets to Redmine.'
  version '0.1.0'
  
  # The data necessary to log into your email server.
  # For this first rev, I am assuming you have an IMAP server
  settings :default => {'email_server' => '',
                        'email_login' => '',
                        'email_password' => '',
                        'use_ssl' => '',
                        'email_port' => '',
                        'email_folder' => 'INBOX'}, :partial => 'settings/settings'

  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :ticket_emailer do
    # This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :view_ticket_emailer, {:ticket_emailer => :show}
  end

  # A new item is added to the project menu
  menu :project_menu, 'Emailer Setup', :controller => 'ticket_emailer', :action => 'show'
end
