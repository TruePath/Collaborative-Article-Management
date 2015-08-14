class AddLibraryRefToLabel < ActiveRecord::Migration
  def change
    add_reference :labels, :library, index: true, foreign_key: true
  end
end
