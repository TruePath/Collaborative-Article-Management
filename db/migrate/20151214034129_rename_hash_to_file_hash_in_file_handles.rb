class RenameHashToFileHashInFileHandles < ActiveRecord::Migration
  def change
  	rename_column :file_handles, :hash, :file_hash
  end
end
