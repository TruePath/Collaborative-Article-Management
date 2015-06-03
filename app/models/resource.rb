class Resource < ActiveRecord::Base
  belongs_to :library
  belongs_to :reference
  acts_as_list :scope => :reference
end

class LocalFile < Resource
end

class Link < Resource
end

