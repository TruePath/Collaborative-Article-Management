class Bibfile < ActiveRecord::Base
	has_attached_file :references_source
	validates_attachment_file_name :references_source, :matches => [/bib\Z/]
	belongs_to :library

end
