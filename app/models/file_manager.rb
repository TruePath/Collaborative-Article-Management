# require 'google/api_client'
# # require 'google/api_client/client_secrets'
# require 'google/api_client/auth/installed_app'
# require 'google/api_client/auth/storage'
# require 'google/api_client/auth/storages/file_store'



class FileManager < ActiveRecord::Base
	#kind:string user:references count:integer
  belongs_to :user, :inverse_of => :file_manager
  serialize :scope, Array
  scope :drive_file_managers, -> { where(type: 'DriveFileManager') }
end


class DriveFileManager < FileManager

	def scope
		return ["https://www.googleapis.com/auth/drive"]
	end


end