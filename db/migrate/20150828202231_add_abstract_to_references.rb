class AddAbstractToReferences < ActiveRecord::Migration
  def change
    add_column :references, :abstract, :text
  end
end
