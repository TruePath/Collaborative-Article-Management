class BibtexFile < Bibfile

	def self.split_entries(file_contents)
    return file_contents.split(/[\n\r]+  (?=[@]  [[:alpha:]]*?   [{])/xm).drop(1)
	end

end
