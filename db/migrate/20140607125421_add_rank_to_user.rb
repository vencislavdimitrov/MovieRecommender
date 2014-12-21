class AddRankToUser < ActiveRecord::Migration
  def change
    add_column :users, :rank, :integer, :default => 0
  end
end
