Deface::Override.new :virtual_path  => 'users/_form',
                     :name          => 'check_admin_checkbox_if_sudoer',
                     :original      => 'e60a4fa50dfadff1543026068000af0103515325',
                     :replace       => 'erb[loud]:contains("f.check_box :admin")',
                     :text          => "<%= f.check_box :admin, checked: (@user.admin? || @user.sudoer?), disabled: (@user == User.current) %>"
