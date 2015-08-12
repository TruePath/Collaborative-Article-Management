class BibtexUploadWorker
	include Resque::Plugins::Status


  def perform #
  	# ActiveRecord::Base.transaction do
  		bibtex_file = BibtexFile.find(options['bibtex_file_id'])
  		library = Library.find(options['library_id'])
	  	raw_entries = BibtexFile.split_entries(Paperclip.io_adapters.for(bibtex_file.references_source).read)
	  	total = raw_entries.length
	  	num = 0
	  	raw_entries.each { |bibtex|
	  		at(num, total, "At #{num} of #{total}")
	  		num += 1
		    entry = RawBibtexEntry.new
		    entry.library = library
		    entry.bibfile = bibtex_file
		    if (RawBibtexEntry.exists?(digest: entry.digest))
		    	entry.destroy
		    else
		    	entry.save
		    end
		   }
	  # end
  end


end