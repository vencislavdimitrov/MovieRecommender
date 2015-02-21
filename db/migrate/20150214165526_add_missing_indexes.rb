class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :movies_users, :movie_id
    add_index :movies_users, [:movie_id, :user_id]
    add_index :movies_users, :user_id
  end
end
