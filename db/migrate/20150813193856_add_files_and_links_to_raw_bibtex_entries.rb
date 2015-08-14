class AddFilesAndLinksToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_column :raw_bibtex_entries, :links, :text
    add_column :raw_bibtex_entries, :filenames, :text
  end
end
