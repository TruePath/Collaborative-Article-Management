class AddSaveFolderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :save_folder, :reference
    add_column :libraries, :save_folder, :reference
  end
end
