class Library < ActiveRecord::Base
	belongs_to :user, counter_cache: true
	has_many :references, dependent: :destroy
	has_many :resources, dependent: :destroy

	def size
		self.references.size
	end
end
