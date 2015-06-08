class AddIndexToAliases < ActiveRecord::Migration
  def change
  	add_index :aliases, :name
  end
end
