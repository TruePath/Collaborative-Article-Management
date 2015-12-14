class FileHandleSerializer < ApplicationSerializer
	include ActiveRecordFields
  attributes :name, :file_hash, :metadata, :size, :fileid, :type
  # embed :ids
  has_one :file_manager
end
