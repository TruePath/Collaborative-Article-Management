module RawBibtexEntriesHelper

	def entry_list_class(raw_bibtex_entry)
		if raw_bibtex_entry.error?
			return "danger"
		elsif raw_bibtex_entry.warning?
			return "warning"
		end
	end

	def bibtex_column_header(column, title = nil)
	  title ||= column.titleize
	  css_class = column == sort_by ? "current" : nil
	  caret_css = column == sort_by ? "#{sort_direction}" : ""
	  direction = column == sort_by && sort_direction == "asc" ? "desc" : "asc"
	  link_to( title, library_raw_bibtex_entries_path(:sort_by => column, :direction => direction), :class => css_class, remote: true) + "<span class='#{caret_css}'></span>".html_safe
	end


end
