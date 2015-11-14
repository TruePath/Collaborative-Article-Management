class CreateFileManagers < ActiveRecord::Migration
  def change
    create_table :file_managers do |t|
      t.string :kind
      t.references :user, index: true, foreign_key: true
      t.integer :count,  :default => 0

      t.timestamps null: false
    end
  end
end
