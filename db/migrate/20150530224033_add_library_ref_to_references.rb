class AddLibraryRefToReferences < ActiveRecord::Migration
  def change
    add_reference :references, :library, index: true, foreign_key: true
  end
end
