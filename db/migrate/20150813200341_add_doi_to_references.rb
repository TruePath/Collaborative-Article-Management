class AddDoiToReferences < ActiveRecord::Migration
  def change
    add_column :references, :doi, :string
    add_index :references, :doi
  end
end
