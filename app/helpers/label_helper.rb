module LabelHelper


	def label_enum(lib, offset="- ")
		Label.walk_labels(lib) { |lab, depth|
			preface = ""
			depth.times do
				preface += offset
			end
			yield lab, preface + lab.name
		}
	end


	def label_select_list(lib, offset="- ")
		list = Array.new
		label_enum(lib, offset) { |lab, name|
			list << [ name, lab.id]
		}
		return list
	end

end
