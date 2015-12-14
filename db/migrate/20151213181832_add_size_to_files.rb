class AddSizeToFiles < ActiveRecord::Migration
  def change
    add_column :files, :size, :integer, :limit => 8
  end
end
