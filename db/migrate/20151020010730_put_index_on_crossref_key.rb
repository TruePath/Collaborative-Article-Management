class PutIndexOnCrossrefKey < ActiveRecord::Migration
  def change
  	change_column :raw_bibtex_entries, :crossrefkey, :string, :default => nil, :index => true, :null => true
  	remove_column :raw_bibtex_entries, :crossref_failure
  end
end
