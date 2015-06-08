class AddAuthorNamesToReferences < ActiveRecord::Migration
  def change
    add_column :references, :author_names, :string
    add_index :references, :author_names
  end
end
