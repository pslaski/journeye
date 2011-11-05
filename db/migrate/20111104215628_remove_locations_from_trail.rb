class RemoveLocationsFromTrail < ActiveRecord::Migration
  def up
    remove_column :trails, :locations
  end

  def down
    add_column :trails, :locations, :string
  end
end
