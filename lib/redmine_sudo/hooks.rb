module RedmineSudo
  class Hooks < Redmine::Hook::ViewListener
    #adds some javascript on each page
    render_on :view_layouts_base_html_head, :partial => 'sudo/toggle_button'
  end
end
