class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :type
      t.string :name
      t.string :hash
      t.integer :position
      t.references :library, index: true, foreign_key: true
      t.references :reference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
