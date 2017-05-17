require 'redmine'
require 'redmine_sudo/hooks'
require 'redmine_sudo/hook_listener'

plugin_name = :redmine_sudo

# Patches to existing classes/modules
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_sudo/user_patch'
end

# Plugin generic informations
Redmine::Plugin.register plugin_name do
  name 'Redmine Sudo plugin'
  description 'This plugin gives sudo-like powers to Redmine administrators'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'https://github.com/jbbarth/redmine_sudo'
  version '0.0.1'
  # requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  settings :default => {
    'become_admin' => 'Стать администратором',
    'become_user' => 'Стать пользователем',
    'additional_css' => "#top-menu { background-color:#BA0C04; }\n
                        #header { background-color:#dd0037; }\n
                        #main-menu li a { background-color:#BA0C04; }\n
                        #main-menu li a.new-object { background-color:#BA0C04; }\n
                        #main-menu li a:hover { background-color:#8D0A02; }\n
                        @media all and (max-width: 899px) { #header{ background-color: #dd0037 !important; }" },
           :partial => 'settings/redmine_sudo_settings'
end

Rails.application.config.after_initialize do
  test_dependencies = {redmine_base_deface: '0.0.1'}
  current_plugin = Redmine::Plugin.find(plugin_name)
  check_dependencies =
      proc do |plugin, version|
        begin
          current_plugin.requires_redmine_plugin(plugin, version)
        rescue Redmine::PluginNotFound
          raise Redmine::PluginNotFound,
                "Redmine sudo depends on plugin: #{plugin} version: #{version}"
        end
      end
  test_dependencies.each(&check_dependencies)
end