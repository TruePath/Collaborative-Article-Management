class AddDigestToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_column :raw_bibtex_entries, :digest, :string
    add_index :raw_bibtex_entries, :digest
  end
end
