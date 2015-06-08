class Link < ActiveRecord::Base
  belongs_to :reference, counter_cache: true, :inverse_of => :links
  acts_as_list :scope => :reference
end
