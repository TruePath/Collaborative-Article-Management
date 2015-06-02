class AuthorshipRecord < ActiveRecord::Base
  belongs_to :reference
  belongs_to :person
  acts_as_list :scope => :reference
end
