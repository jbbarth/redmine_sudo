Deface::Override.new :virtual_path  => 'users/_form',
                     :name          => 'check_admin_checkbox_if_sudoer',
                     :replace       => 'erb[loud]:contains("f.check_box :admin")',
                     :text          => "<% if User.current.admin? %><%= f.check_box :admin, checked: (@user.admin? || @user.sudoer?), disabled: (@user == User.current) %><% end %>"
