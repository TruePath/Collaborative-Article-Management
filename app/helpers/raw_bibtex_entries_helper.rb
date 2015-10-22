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

	def markup_messages(msgs)
		output = ""
		msgs.each { |msg|
				output += msg.is_error? ? '<span class="text-danger">' : '<span class="text-warning">'
				output += strip_tags(msg.text)
				output += '</span>'
				output += "<br />\n"
		}
		return output
	end

	def markup_bibtex(entry)
		output = markup_messages(entry.messages.messages_for_line(-1))
		line = 0
		entry.content.each_line do |bibtex_line|
			output += strip_tags(bibtex_line)
			output += "<br />"
			output += markup_messages(entry.messages.messages_for_line(line))
			line += 1
		end
		return output.html_safe
	end


end
