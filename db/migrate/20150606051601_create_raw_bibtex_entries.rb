class CreateRawBibtexEntries < ActiveRecord::Migration
  def change
    create_table :raw_bibtex_entries do |t|
      t.references :library, index: true, foreign_key: true
      t.text :content
      t.integer :position
      t.references :reference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
