module RedmineSudo
  class Hooks < Redmine::Hook::ViewListener
    #adds some javascript on each page
    render_on :view_layouts_base_html_head, :partial => 'sudo/sudo_styles'
  end
end
