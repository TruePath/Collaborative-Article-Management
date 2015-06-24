class RemovePositionFromRawBibtexEntries < ActiveRecord::Migration
  def change
  	remove_column :raw_bibtex_entries, :position
  end
end
