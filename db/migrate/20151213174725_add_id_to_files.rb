class AddIdToFiles < ActiveRecord::Migration
  def change
    add_column :files, :fileid, :string
    add_index :files, :fileid, unique: true
    add_column :files, :metadata, :text
    add_column :files, :name, :string
    add_index :files, :name
    add_column :files, :hash, :string
    add_index :files, :hash
    remove_column :files, :handle
  end
end
