class Reference < ActiveRecord::Base
	has_many :fields
	has_many :authorship_records, :dependent => :destroy, :order => 'position'
	has_many :persons, :through => :authorship_records, :order => 'position'
	belongs_to :parent, class_name: "Reference"
	belongs_to :library, counter_cache: true
end
