module RawBibtexEntriesHelper

	def raw_bibtex_list_class(raw_bibtex_entry)
		if raw_bibtex_entry.error?
			return "danger"
		elsif raw_bibtex_entry.warning?
			return "warning"
		end
	end

	def bibtex_column_header(column, title = nil)
	  sort_column_header(column, title) { |p| library_raw_bibtex_entries_path(@library, p)}
	end


end
