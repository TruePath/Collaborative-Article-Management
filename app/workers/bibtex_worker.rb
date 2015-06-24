class BibtexWorker
	include Resque::Plugins::Status


  def perform #
  	# ActiveRecord::Base.transaction do
  		bibtex_file = BibtexFile.find(options['bibtex_file_id'])
  		library = Library.find(options['library_id'])
	  	raw_entries = Paperclip.io_adapters.for(bibtex_file.references_source).read.split(/[\n\r]+  (?=[@]  [[:alpha:]]*?   [{])/xm)
	  	total = raw_entries.length
	  	num = 0
	  	raw_entries.each { |bibtex|
	  		at(num, total, "At #{num} of #{total}")
	  		num += 1
		    entry = RawBibtexEntry.new
		    entry.library = library
		    entry.bibfile = bibtex_file
		    entry.build_from_bibtex(bibtex.force_encoding("UTF-8"))
		    entry.save
		   }
	  # end
  end


end