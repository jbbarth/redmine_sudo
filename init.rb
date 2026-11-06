# frozen_string_literal: true

require 'redmine'

# Plugin registration
Redmine::Plugin.register :redmine_sudo do
  name 'Redmine Sudo plugin'
  description 'Allow Redmine administrators to drop their admin privileges to work as a normal user and provide an audit log of privileged actions'
  author 'Jean-Baptiste BARTH (orig)'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'https://github.com/tools-aoeur/redmine_sudo'
  version '6.1.4'
  requires_redmine version_or_higher: '6.1.4'

  Redmine::MenuManager.map :account_menu do |menu|
    menu.push :sudo, :sudo_toggle_path,
              html: { method: 'post',
                      id: 'sudo_id' },
              caption: proc {
                Setting.plugin_redmine_sudo[User.current.admin? ? 'become_user' : 'become_admin']
              },
              before: :my_account,
              class: 'sudo',
              if: proc { User.current.can_become_admin? }
  end

  Redmine::MenuManager.map :admin_menu do |menu|
    menu.push :security_audit_log, :security_audit_logs_path,
              caption: :label_security_audit_log,
              icon: 'redmine_sudo',
              plugin: :redmine_sudo,
              html: { class: 'icon icon-redmine_sudo' },
              if: proc { User.current.admin? }
  end

  settings default: {
             'become_admin' => 'Become Admin',
             'become_user' => 'Become User'
           },
           partial: 'settings/redmine_sudo_settings'
end

# Apply patches.

# View hooks (triggers Zeitwerk autoload + render_on registration)
_ = RedmineSudo::Hooks

# User model
unless User.ancestors.include?(RedmineSudo::UserPatch)
  User.prepend RedmineSudo::UserPatch
  User.safe_attributes 'sudoer', if: proc { |_user, current_user| current_user.admin? }
end

# Mailer: "all administrators" broadcasts must also reach sudoers
unless Mailer.singleton_class.ancestors.include?(RedmineSudo::MailerPatch)
  Mailer.singleton_class.prepend RedmineSudo::MailerPatch
end

# UserQuery
unless UserQuery.ancestors.include?(RedmineSudo::UserQueryPatch)
  UserQuery.prepend RedmineSudo::UserQueryPatch
end
unless UserQuery.available_columns.any? { |c| c.name == :sudoer }
  UserQuery.available_columns << QueryColumn.new(:sudoer, sortable: "#{User.table_name}.sudoer")
end

unless ApplicationController.ancestors.include?(RedmineSudo::ApplicationControllerPatch)
  ApplicationController.prepend RedmineSudo::ApplicationControllerPatch
end

# Security audit trail
unless SudoController.ancestors.include?(RedmineSudo::Audit::SudoControllerPatch)
  SudoController.prepend RedmineSudo::Audit::SudoControllerPatch
end

{ UsersController       => RedmineSudo::Audit::UsersControllerPatch,
  ProjectsController    => RedmineSudo::Audit::ProjectsControllerPatch,
  MembersController     => RedmineSudo::Audit::MembersControllerPatch,
  RolesController       => RedmineSudo::Audit::RolesControllerPatch,
  GroupsController      => RedmineSudo::Audit::GroupsControllerPatch,
  SettingsController    => RedmineSudo::Audit::SettingsControllerPatch,
  AuthSourcesController => RedmineSudo::Audit::AuthSourcesControllerPatch }.each do |klass, mod|
  klass.include mod unless klass.ancestors.include?(mod)
end
