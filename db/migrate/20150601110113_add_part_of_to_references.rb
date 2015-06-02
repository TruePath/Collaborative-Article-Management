class AddPartOfToReferences < ActiveRecord::Migration
  def change
    add_reference :references, :parent, references: :references, index: true, foreign_key: true
  end
end
