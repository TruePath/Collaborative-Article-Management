class Reference < ActiveRecord::Base
	include Filterable
	#title:string, key:string, bibtex_type:string, year:integer, authors:text, month:string, doi:string
	acts_as_taggable # Alias for acts_as_taggable_on :tags
	acts_as_taggable_on :subjects, :keywords
	has_many :fields, :inverse_of => :reference, autosave: true
	has_many :authorship_records,  -> { order 'authorship_records.position' }, :inverse_of => :reference, :dependent => :destroy
	has_many :persons, -> { order 'authorship_records.position' }, :through => :authorship_records
	has_many :resources, -> { order 'resources.position' }
	has_many :links, -> { order 'links.position' }, :inverse_of => :reference, autosave: true
	has_many :children, class_name: "Reference", foreign_key: "parent_id"
	has_many :raw_children, class_name: "RawBibtexEntry", foreign_key: "parent_record_id", as: :parent_record
  has_many :author_names,  -> { order 'author_names.position' }, class_name: "AuthorName", foreign_key: "entry_id", :as => :entry, :dependent => :destroy
	has_one :raw_bibtex_entry, :inverse_of => :reference
	belongs_to :parent, class_name: "Reference"
	belongs_to :library, counter_cache: true, :inverse_of => :references
	has_and_belongs_to_many :labels, counter_cache: true

	accepts_nested_attributes_for :fields, allow_destroy: true, reject_if:  proc { |attributes| attributes['name'].blank? || attributes['value'].blank? }
	accepts_nested_attributes_for :author_names, allow_destroy: true, reject_if:  proc { |attributes| attributes['name'].blank? }
	accepts_nested_attributes_for :links, allow_destroy: true, reject_if:  proc { |attributes| attributes['uri'].blank? }

	scope :label, -> (id) { joins(:labels).where( "labels.id = ?", id) if id.present? }
  scope :key, -> (str) {where("key LIKE ?", "%#{str.to_s}%") if str.present?}
  scope :title, -> (str) {where("title LIKE ?", "%#{str.to_s}%") if str.present?}
  scope :author, -> (str) {where("authors LIKE ?", "%#{str.to_s}%") if str.present?}
  scope :year, -> (str) {where("year LIKE ?", "%#{str.to_s}%") if str.present?}
  scope :fulltext, -> (str) {where("abstract LIKE ?", "%#{str.to_s}%") if str.present?}


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

  def authors
    self.author_names.to_a.join(' and ')
  end

  def authors=(val)
    self.author_names.destroy
    val.strip.split(/(?:[ ]and[ ])|\;/).each {|entry|
      self.author_names << AuthorName.new(name: entry)
    }
  end

 def special_attributes
 	return [:year, :month, :key, :bibtex_type, :title, :authors]
 end

 def attributes
 	super.merge({'authors' => self.send(:authors)})
 end

end
