class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.references :file_manager, index: true, foreign_key: true
      t.string :path
      t.text :handle

      t.timestamps null: false
    end
  end
end
