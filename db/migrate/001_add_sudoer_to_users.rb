class AddSudoerToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :sudoer, :boolean, :default => false, :null => false
    User.all.each do |user|
      user.update_attribute(:sudoer, true) if user.admin?
    end
  end

  def self.down
    remove_column :users, :sudoer
  end
end
