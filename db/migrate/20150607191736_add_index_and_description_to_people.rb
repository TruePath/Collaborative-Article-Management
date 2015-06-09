class AddIndexAndDescriptionToPeople < ActiveRecord::Migration
  def change
    add_column :people, :description, :string
    add_index :people, :description
  end
end
