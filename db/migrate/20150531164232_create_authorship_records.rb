class CreateAuthorshipRecords < ActiveRecord::Migration
  def change
    create_table :authorship_records do |t|
      t.integer :position
      t.references :reference, index: true, foreign_key: true
      t.references :person, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
