class AddRankToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :rank, :integer, :default => 0
  end
end
