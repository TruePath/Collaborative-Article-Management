module LabelHelper




	def label_select_list(lib, offset="- ")
		list = Array.new
		Label.walk_labels(lib) { |lab, depth|
			preface = ""
			depth.times do
				preface += offset
			end
			list << [lab.id, preface]
		}
		return list
	end

end
