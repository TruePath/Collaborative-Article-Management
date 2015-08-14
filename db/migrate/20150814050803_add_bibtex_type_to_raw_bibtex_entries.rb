class AddBibtexTypeToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_column :raw_bibtex_entries, :bibtex_type, :string
  end
end
