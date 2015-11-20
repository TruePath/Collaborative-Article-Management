class Resource < ActiveRecord::Base
	#name, filename
  belongs_to :library, :inverse_of => :resources
  belongs_to :reference, counter_cache: true, :inverse_of => :resources
  acts_as_list :scope => :reference
end

class LocalFile < Resource
end

class GoogleDriveFile < Resource
end


