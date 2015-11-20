class AddAuthDataToFileManager < ActiveRecord::Migration
  def change
    add_column :file_managers, :auth_data, :text
    add_column :file_managers, :account, :string
    remove_column :file_managers, :kind
    remove_column :file_managers, :folder
  end
end
