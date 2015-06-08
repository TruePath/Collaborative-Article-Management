class AuthorshipRecord < ActiveRecord::Base
  belongs_to :reference, :inverse_of => :authorship_records
  belongs_to :person, :inverse_of => :authorship_records
  acts_as_list :scope => :reference
end
