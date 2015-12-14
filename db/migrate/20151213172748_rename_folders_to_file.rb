class RenameFoldersToFile < ActiveRecord::Migration
  def change
  	rename_table :folders, :files
  end
end
