class CreateTrails < ActiveRecord::Migration
  def change
    create_table :trails do |t|
      t.string :name
      t.string :locations
      t.integer :distance
      t.integer :highest
      t.integer :lowest
      t.text :uri
      t.text :img_uri
      t.text :chart_uri

      t.timestamps
    end
  end
end
