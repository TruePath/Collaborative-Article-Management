class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :name
      t.references :parent, index: true, foreign_key: true
      t.integer :count

      t.timestamps null: false
    end
    add_index :labels, :name
  end
end
