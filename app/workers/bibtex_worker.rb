class BibtexWorker
  include Sidekiq::Worker
  # include SidekiqStatus::Worker
  sidekiq_options :retry => false # job will be discarded immediately if failed


  def perform(bibtex_file, library) #upload may be a tempfile or stringio
  	# ActiveRecord::Base.transaction do
	  	Paperclip.io_adapters.for(bfile.references_source).read,.split(/[\n\r]+  (?=[@]  [[:alpha:]]*?   [{])/xm).each { |bibtex|
	    entry = RawBibtexEntry.new
	    entry.library = library
	    entry.bibfile = bibtex_file
	    entry.build_from_bibtex(bibtex.force_encoding("UTF-8"))
	    entry.save
	   }
	  # end
  end


end