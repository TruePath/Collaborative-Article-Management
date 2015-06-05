class Library < ActiveRecord::Base
	belongs_to :user
	has_many :references, dependent: :destroy
	has_many :resources, dependent: :destroy
# name: string
# description: string


	def size
		self.references.size
	end
end
