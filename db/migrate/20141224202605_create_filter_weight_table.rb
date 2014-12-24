class CreateFilterWeightTable < ActiveRecord::Migration
  def change
    create_table :filter_weights do |t|
      t.column :name, :string
      t.column :weight, :float

      t.timestamps
    end

    FilterWeight.create({:name => 'trusted', :weight => 10})
    FilterWeight.create({:name => 'collaborative', :weight => 10})
  end
end
