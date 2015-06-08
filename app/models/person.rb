class Person < ActiveRecord::Base
	has_many :authorship_records, :dependent => :destroy, :inverse_of => :person
	has_many :references, :through => :authorship_records
	has_many :aliases, :dependent => :destroy, :inverse_of => :person
end
