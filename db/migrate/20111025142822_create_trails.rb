class CreateTrails < ActiveRecord::Migration
  def change
    create_table :trails do |t|
      t.string :longitude_start
      t.string :latitude_start
      t.string :longitude_end
      t.string :latitude_end
      t.text :map_url

      t.timestamps
    end
  end
end
