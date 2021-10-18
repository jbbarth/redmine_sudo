Deface::Override.new :virtual_path  => 'users/index',
                     :name          => 'add-sudoer-info-to-admin-users-table',
                     :original      => 'edc31bce1cac515de516f73c53f92a61c942301f',
                     :replace       => 'td.tick',
                     :partial       => 'sudo/users-table'
