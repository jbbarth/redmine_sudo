class AddSudoerToUsers < ActiveRecord::Migration
  def up
    add_column :users, :sudoer, :boolean, :default => false, :null => false
  end

  def down
    remove_column :users, :sudoer
  end
end
