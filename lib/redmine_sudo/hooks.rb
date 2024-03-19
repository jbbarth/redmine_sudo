module RedmineSudo
  class Hooks < Redmine::Hook::ViewListener
    # adds some javascript on each page
    render_on :view_layouts_base_html_head, :partial => 'sudo/sudo_styles'
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'user_patch'
      require_relative 'users_controller_patch'
    end
  end
end
