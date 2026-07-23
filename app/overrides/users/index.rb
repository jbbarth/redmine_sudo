Deface::Override.new :virtual_path  => 'users/index',
                     :name          => 'add-sudoer-info-to-admin-users-table',
                     :replace       => 'td.tick:first',
                     :partial       => 'sudo/users-table'
