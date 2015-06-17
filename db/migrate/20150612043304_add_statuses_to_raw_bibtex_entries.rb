class AddStatusesToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_column :raw_bibtex_entries, :error, :boolean
    add_index :raw_bibtex_entries, :error
    add_column :raw_bibtex_entries, :warning, :boolean
    add_index :raw_bibtex_entries, :warning
    add_column :raw_bibtex_entries, :messages, :text
    add_reference :raw_bibtex_entries, :parent_record, polymorphic: true
    add_index :raw_bibtex_entries, :parent_record_id
    add_column :raw_bibtex_entries, :crossref_failure, :boolean
    add_index :raw_bibtex_entries, :crossref_failure
    add_column :raw_bibtex_entries, :key, :string
    add_column :raw_bibtex_entries, :crossrefkey, :string
    add_index :raw_bibtex_entries, :key
  end
end
