Deface::Override.new :virtual_path  => 'layouts/base',
                     :name          => 'add-sudo-toggle-to-layout',
                     :original      => '71965edcd54e62e58396dcaad58baa5872a7e8dc',
                     :insert_after  => '#account',
                     :partial       => 'sudo/sudo_link'
