class AddAuthorshipTypeToReferences < ActiveRecord::Migration
  def change
    add_column :references, :authorship_type, :string
  end
end
