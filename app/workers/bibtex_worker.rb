class BibtexWorker
	@queue = :parse


  def self.perform(bibtex_file_id, library_id) #upload may be a tempfile or stringio
  	# ActiveRecord::Base.transaction do
  		bibtex_file = BibtexFile.find(bibtex_file_id)
  		library = Library.find(library_id)
	  	Paperclip.io_adapters.for(bibtex_file.references_source).read.split(/[\n\r]+  (?=[@]  [[:alpha:]]*?   [{])/xm).each { |bibtex|
	    entry = RawBibtexEntry.new
	    entry.library = library
	    entry.bibfile = bibtex_file
	    entry.build_from_bibtex(bibtex.force_encoding("UTF-8"))
	    entry.save
	   }
	  # end
  end


end