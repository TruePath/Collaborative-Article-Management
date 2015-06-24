class AddWarningsAndErrorsToRawBibtexEntries < ActiveRecord::Migration
  def change
    add_column :raw_bibtex_entries, :num_warnings, :integer
    add_column :raw_bibtex_entries, :num_errors, :integer
    remove_column :raw_bibtex_entries, :warning
    remove_column :raw_bibtex_entries, :error
  end
end
