class AddAttachmentToBibfiles < ActiveRecord::Migration
  def up
    add_attachment :bibfiles, :references_source
  end

  def down
    remove_attachment :bibfiles, :references_source
  end
end
