class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.decimal :fb_id, :precision => 32
      t.string :name

      t.timestamps
    end
  end
end
