class RemoveDistanceFromTrail < ActiveRecord::Migration
  def up
    remove_column :trails, :distance
  end

  def down
    add_column :trails, :distance, :integer
  end
end
