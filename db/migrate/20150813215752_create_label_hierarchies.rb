class CreateLabelHierarchies < ActiveRecord::Migration
  def change
    create_table :label_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :label_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "label_anc_desc_idx"

    add_index :label_hierarchies, [:descendant_id],
      name: "label_desc_idx"
  end
end
