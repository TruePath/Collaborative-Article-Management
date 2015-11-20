class AddStateToFileManager < ActiveRecord::Migration
  def change
    add_column :file_managers, :state, :string
  end
end
