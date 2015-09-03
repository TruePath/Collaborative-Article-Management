class CreateAuthorNames < ActiveRecord::Migration
  def change
    create_table :author_names do |t|
      t.string :name
      t.references :entry, polymorphic: true, index: true
      t.integer :position

      t.timestamps null: false
    end
  end
end
