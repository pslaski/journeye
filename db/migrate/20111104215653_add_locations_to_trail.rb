class AddLocationsToTrail < ActiveRecord::Migration
  def change
    add_column :trails, :locations, :text
  end
end
