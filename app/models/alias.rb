class Alias < ActiveRecord::Base
  belongs_to :person, :inverse_of => :aliases
end
