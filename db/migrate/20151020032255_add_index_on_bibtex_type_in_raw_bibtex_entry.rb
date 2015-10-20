class AddIndexOnBibtexTypeInRawBibtexEntry < ActiveRecord::Migration
  def change
  	add_index :raw_bibtex_entries, :bibtex_type
  end
end
