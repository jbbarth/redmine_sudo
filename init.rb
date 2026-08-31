require 'redmine'
require_relative 'lib/redmine_sudo/hooks'

Rails.autoloaders.main.ignore("#{__dir__}/lib") if Rails::VERSION::MAJOR >= 6

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
    # Default styles for the Redmine 7.0 default theme: the red counterpart of
    # the blue/indigo ramp used by the core stylesheet.
    'additional_css' => <<~CSS,
      #top-menu { background-color: #6b1f1f; }

      #header { background-color: var(--oc-red-9); }

      #main-menu {
        background-color: var(--oc-red-0);
        --color-current-marker: var(--oc-red-8);
      }
      #main-menu li a:hover { background-color: var(--oc-red-1); }
      #main-menu li a.new-object { background-color: var(--oc-red-1); border-color: var(--oc-red-7); }
      #main-menu li a.new-object:hover { background-color: var(--oc-red-2); }
      #main-menu .menu-children { border-color: var(--oc-red-7); }
      #main-menu .menu-children li a:hover { background-color: var(--oc-red-9); }

      @media all and (max-width: 899px) {
        #header { background-color: var(--oc-red-8); }
        .flyout-menu { background-color: #8f2f2f; }
      }
    CSS
    'require_oidc_for_sudo' => '',
    'required_oidc_auth_level' => '',
    'oidc_error_message' => '',
    'api_sudoer_always_admin' => '1'
           },
           :partial => 'settings/redmine_sudo_settings'
end
