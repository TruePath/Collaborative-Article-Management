class Field < ActiveRecord::Base
	#name:string, value:string
	validates_presence_of :reference
	before_save :delete_if_empty
  belongs_to :reference, :inverse_of => :fields

  private

  def delete_if_empty
		if self.name.empty? || self.value.empty?
			self.destroy
			return false
		end
		return true
	end

end
