class RenameFilesToFileHandles < ActiveRecord::Migration
  def change
  	rename_table :files, :file_handles
  end
end
