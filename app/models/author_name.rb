class AuthorName < ActiveRecord::Base
	# name:string, entry:references{polymorphic}
	before_validation :reorder_names
	before_save :delete_if_empty
  belongs_to :entry, polymorphic: true
  validates_presence_of :entry
  acts_as_list scope: [:entry_id, :entry_type]


  private

	def reorder_names
		split_names = self.name.partition(',')
		self.name = split_names[0] + " " + split_names[2] unless (split_names[0].empty? || split_names[2].empty?)
		return true
	end

	def delete_if_empty
		if self.name.empty?
			self.destroy
			return false
		end
		return true
	end



end
