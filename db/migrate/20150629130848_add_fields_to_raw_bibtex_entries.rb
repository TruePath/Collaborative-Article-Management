class AddFieldsToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_column :raw_bibtex_entries, :fields, :text
  end
end
