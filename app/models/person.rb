class Person < ActiveRecord::Base
	acts_as_taggable # Alias for acts_as_taggable_on :tags
	acts_as_taggable_on :subjects, :keywords, :places
	has_many :authorship_records, :dependent => :destroy, :inverse_of => :person
	has_many :references, :through => :authorship_records
	has_many :aliases, :dependent => :destroy, :inverse_of => :person
end
