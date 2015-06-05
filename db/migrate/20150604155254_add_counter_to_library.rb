class AddCounterToLibrary < ActiveRecord::Migration
  def change
    add_column :libraries, :references_count, :integer, :default => 0
  end
end
