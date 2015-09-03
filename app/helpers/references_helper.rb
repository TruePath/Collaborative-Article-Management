module ReferencesHelper


	def references_column_header(column, title = nil)
	  sort_column_header(column, title) { |p|  library_references_path(@library, p) }
	end

end
