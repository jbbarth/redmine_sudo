class RedmineSudo::HookListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_account_before,
            partial: 'hooks/redmine_sudo/sudo_link'
end