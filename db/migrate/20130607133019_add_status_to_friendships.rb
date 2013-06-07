class AddStatusToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :pending, :boolean, default: true
    add_column :friendships, :mutual, :boolean, default: false
  end
end
