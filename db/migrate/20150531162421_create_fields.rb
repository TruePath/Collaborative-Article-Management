class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.string :value
      t.references :reference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
