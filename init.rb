require 'redmine'
require_relative 'lib/redmine_sudo/hooks'

Rails.autoloaders.main.ignore("#{__dir__}/lib")

# Plugin generic informations
Redmine::Plugin.register :redmine_sudo do
  name 'Redmine Sudo plugin'
  description 'This plugin gives sudo-like powers to Redmine administrators'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'https://github.com/jbbarth/redmine_sudo'
  version '5.0.0'
  requires_redmine :version_or_higher => '2.5.0'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'

  Redmine::MenuManager.map :account_menu do |menu|
    menu.push :sudo, :sudo_toggle_path,
              html: { method: 'get',
                      id: "sudo_id" },
              caption: Proc.new {
                User.current.admin? ? Setting.plugin_redmine_sudo["become_user"] : Setting.plugin_redmine_sudo["become_admin"]
              },
              before: :my_account,
              class: "sudo",
              if: Proc.new { User.current.sudoer? }

  end

  settings :default => {
    'become_admin' => '[sudo -v]',
    'become_user' => '[sudo -k]',
    'additional_css' => "#top-menu { background-color:#BA0C04; }\n
                        #header { background-color:#dd0037; }\n
                        #main-menu li a { background-color:#BA0C04; }\n
                        #main-menu li a.new-object { background-color:#BA0C04; }\n
                        #main-menu li a:hover { background-color:#8D0A02; }\n
                        @media all and (max-width: 899px) { #header{ background-color: #dd0037 !important; }" },
           :partial => 'settings/redmine_sudo_settings'
end
