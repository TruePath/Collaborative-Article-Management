class FileHandle < ActiveRecord::Base
	#fileid:string, name:string, path:string, file_hash:string, size:bigint
	belongs_to :file_manager, inverse_of: :file_handles
	serialize :metadata, Hash
end


class Folder < FileHandle
end


class Document < FileHandle
end

