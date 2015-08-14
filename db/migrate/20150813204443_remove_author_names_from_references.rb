class RemoveAuthorNamesFromReferences < ActiveRecord::Migration
  def change
  	remove_column :references, :author_names
  	add_column :references, :authors, :text
  	add_column :raw_bibtex_entries, :authors, :text
  	add_column :raw_bibtex_entries, :authorship_type, :string
  end
end
