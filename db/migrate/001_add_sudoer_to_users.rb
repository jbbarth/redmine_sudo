class AddSudoerToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sudoer, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :sudoer
  end
end
