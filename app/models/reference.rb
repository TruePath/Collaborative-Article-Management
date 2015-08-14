class Reference < ActiveRecord::Base
	#title:string, key:string, bibtex_type:string, year:integer, authors:text, month:string, doi:string
	acts_as_taggable # Alias for acts_as_taggable_on :tags
	acts_as_taggable_on :subjects, :keywords
	has_many :fields, :inverse_of => :reference
	has_many :authorship_records,  -> { order 'authorship_records.position' }, :inverse_of => :reference, :dependent => :destroy
	has_many :persons, -> { order 'authorship_records.position' }, :through => :authorship_records
	has_many :resources, -> { order 'resources.position' }
	has_many :links, -> { order 'links.position' }, :inverse_of => :reference
	has_many :children, class_name: "Reference", foreign_key: "parent_id"
	has_many :raw_children, class_name: "RawBibtexEntry", foreign_key: "parent_record_id", as: :parent_record
	has_one :raw_bibtex_entry, :inverse_of => :reference
	belongs_to :parent, class_name: "Reference"
	belongs_to :library, counter_cache: true, :inverse_of => :references
	has_and_belongs_to_many :labels, counter_cache: true
	serialize :authors, Array

	accepts_nested_attributes_for :fields, allow_destroy: true, reject_if:  :reject_field

	def reject_field(attributes)
		exists = attributes['id'].present?
		empty = (attributes['name'].blank? || attributes['value'].blank?)
		attributes.merge!({:_destroy => 1}) if exists and empty
  	return (!exists and empty)
	end

	def num_links
		self.links_count
	end

	def num_files
		self.resources_count
	end

	def can_view?(user)
		return (self.library.user == user)
	end

	def can_edit?(user)
		return (self.library.user == user)
	end

end
