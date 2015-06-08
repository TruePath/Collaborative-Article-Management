class AddMonthToReferences < ActiveRecord::Migration
  def change
    add_column :references, :month, :string
  end
end
