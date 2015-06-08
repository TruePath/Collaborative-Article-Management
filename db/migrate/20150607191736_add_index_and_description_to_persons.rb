class AddIndexAndDescriptionToPersons < ActiveRecord::Migration
  def change
    add_column :persons, :description, :string
    add_index :persons, :description
  end
end
