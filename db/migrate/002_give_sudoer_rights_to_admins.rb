class GiveSudoerRightsToAdmins < ActiveRecord::Migration
  def up
    User.where(:admin => true).update_all(:sudoer => true)
  end

  def down
    User.where(:sudoer => true).update_all(:admin => true, :sudoer => false)
  end
end
