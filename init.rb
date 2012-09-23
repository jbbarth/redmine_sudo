require 'redmine'
require 'redmine_sudo/hooks'

# Rails 3 compat
reloader = Redmine::VERSION::MAJOR <= 1 ? config : ActionDispatch::Callbacks

# Patches to existing classes/modules
reloader.to_prepare do
  require_dependency 'redmine_sudo/user_patch'
end

# Plugin generic informations
Redmine::Plugin.register :redmine_sudo do
  name 'Redmine Sudo plugin'
  description 'This plugin gives sudo-like powers to Redmine administrators'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'http://github.com/jbbarth/redmine_sudo'
  version '0.0.1'
  requires_redmine :version_or_higher => '2.1.0'
  #settings :default => { }, :partial => 'settings/sudo_settings'
end
