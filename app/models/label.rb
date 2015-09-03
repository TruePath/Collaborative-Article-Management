class Label < ActiveRecord::Base
  acts_as_tree name_column: "name", order: 'name', dependent: :destroy
  belongs_to :library
  has_and_belongs_to_many :references
  scope :in_library, ->(library) { where(:library => library) }

def self.roots_in_library(lib)
	Label.where({:library => lib, :parent_id => nil})
end

def walk_subtree(enter = Proc.new {}, exit = Proc.new {}, depth = nil, &b) #block taking name, depth
	depth = depth || self.depth
	b.call(self, depth)
	c =self.children
	enter.call unless c.length == 0
	c.each { |child|
		child.walk_subtree(enter, exit, depth + 1, &b)
	}
	exit.call unless c.length == 0
end

def self.walk_labels(lib, enter = Proc.new {}, exit = Proc.new {}, &b)
	Label.roots_in_library(lib).each { |lab|
		lab.walk_subtree(enter, exit, 0, &b)
	}
end

end
