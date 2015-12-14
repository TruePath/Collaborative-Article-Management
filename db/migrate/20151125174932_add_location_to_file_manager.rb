class AddLocationToFileManager < ActiveRecord::Migration
  def change
    add_column :file_managers, :location, :string
  end
end
