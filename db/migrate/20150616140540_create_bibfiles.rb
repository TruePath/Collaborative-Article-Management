class CreateBibfiles < ActiveRecord::Migration
  def change
    create_table :bibfiles do |t|
    	t.string :type
    	t.references :library, index: true, foreign_key: true
    	t.boolean :import, default: true
    	t.boolean :processed, default: false
      t.timestamps null: false
    end
  end
end
