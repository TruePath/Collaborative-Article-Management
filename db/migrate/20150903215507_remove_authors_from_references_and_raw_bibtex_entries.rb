class RemoveAuthorsFromReferencesAndRawBibtexEntries < ActiveRecord::Migration
  def change
  	remove_column :references, :authors
  	remove_column :raw_bibtex_entries, :authors
  end
end
