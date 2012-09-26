Deface::Override.new :virtual_path  => 'layouts/base',
                     :name          => 'add-sudo-toggle-to-layout',
                     :insert_after  => '#account',
                     :partial       => 'sudo/sudo_link'
