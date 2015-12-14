class AddTypeToFiles < ActiveRecord::Migration
  def change
    add_column :files, :type, :string
  end
end
