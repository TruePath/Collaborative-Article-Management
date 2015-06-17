class AddBibfileToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_reference :raw_bibtex_entries, :bibfile, index: true, foreign_key: true
  end
end
