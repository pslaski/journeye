class AddDistanceToTrail < ActiveRecord::Migration
  def change
    add_column :trails, :distance, :float
  end
end
