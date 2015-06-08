class AddBibtexTypeAndYearAndCountsToReferences < ActiveRecord::Migration
  def change
    add_column :references, :bibtex_type, :string
    add_column :references, :year, :integer
    add_column :references, :resources_count, :integer, :default => 0
    add_column :references, :links_count, :integer, :default => 0
  end
end
