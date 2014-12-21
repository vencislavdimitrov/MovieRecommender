class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_id
      t.integer :rank, :default => 0

      t.timestamps

      t.index [:user_id, :friend_id], :unique => true
    end
  end
end
