class AddFieldsToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :poster, :string
    add_column :movies, :plot, :text
    add_column :movies, :genres, :string
    add_column :movies, :imdb_id, :string
    add_column :movies, :release_date, :date
    add_column :movies, :cast_members, :string
    change_column :movies, :rank, :float
  end
end
