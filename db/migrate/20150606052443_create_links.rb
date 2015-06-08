class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :reference, index: true, foreign_key: true
      t.string :kind
      t.string :uri
      t.integer :position

      t.timestamps null: false
    end
  end
end
