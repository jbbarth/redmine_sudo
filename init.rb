require 'redmine'

# Patches to existing classes/modules
config.to_prepare do
  # nothing for now
end

# Plugin generic informations
Redmine::Plugin.register :redmine_sudo do
  name 'Redmine Sudo plugin'
  description 'This plugin gives sudo-like powers to Redmine administrators'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'http://github.com/jbbarth/redmine_sudo'
  version '0.0.1'
  requires_redmine :version_or_higher => '1.4.0'
  #settings :default => { }, :partial => 'settings/sudo_settings'
end
