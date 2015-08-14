class CreateJoinTableLabelReference < ActiveRecord::Migration
  def change
    create_join_table :labels, :references do |t|
      # t.index [:label_id, :reference_id]
      # t.index [:reference_id, :label_id]
    end
  end
end
