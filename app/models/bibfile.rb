class Bibfile < ActiveRecord::Base
	has_attached_file :references_source
	validates_attachment_file_name :references_source, :matches => [/bib\Z/]
	belongs_to :library
	has_many :raw_bibtex_entries


	def set_parent_records
  	self.raw_bibtex_entries.where("crossrefkey is not NULL").find_each { |entry|
      entry.set_parent_record
  	}
	end

end
