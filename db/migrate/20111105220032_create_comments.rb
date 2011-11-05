class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :trail
      t.string :author
      t.text :body

      t.timestamps
    end
    add_index :comments, :trail_id
  end
end
