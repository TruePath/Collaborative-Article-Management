class Field < ActiveRecord::Base
	#name:string, value:string
  belongs_to :reference, :inverse_of => :fields
end
