class Library < ActiveRecord::Base
	default_scope { order('created_at') }
	paginates_per 10
	belongs_to :user, :inverse_of => :libraries
	has_many :references, dependent: :destroy, :inverse_of => :library
	has_many :resources, dependent: :destroy, :inverse_of => :library
	has_many :raw_bibtex_entries, -> { order(position: :asc) },  dependent: :delete_all, :inverse_of => :library
	has_one :bibfile, dependent: :destroy, :inverse_of => :library
# name: string
# description: string


	def size
		self.references.size
	end

	def can_view?(user)
		return (user == self.user)
	end

	def can_edit?(user)
		return (user == self.user)
	end
end
