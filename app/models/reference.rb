class Reference < ActiveRecord::Base
	has_many :fields
	has_many :authorship_records,  -> { order 'authorship_records.position' }, :dependent => :destroy
	has_many :persons, -> { order 'authorship_records.position' }, :through => :authorship_records
	belongs_to :parent, class_name: "Reference"
	belongs_to :library, counter_cache: true
end
