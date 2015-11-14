class AddFilenameToResource < ActiveRecord::Migration
  def change
    add_column :resources, :filename, :string
    add_index :resources, :filename
    add_column :resources, :altfilename, :string
    add_index :resources, :altfilename
    add_column :resources, :full_path, :string
  end
end
