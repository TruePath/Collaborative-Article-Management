class AddTypeAndOAuthToFileManager < ActiveRecord::Migration
  def change
    add_column :file_managers, :type, :string
    add_column :file_managers, :scope, :text
    add_column :file_managers, :folder, :string
  end
end
