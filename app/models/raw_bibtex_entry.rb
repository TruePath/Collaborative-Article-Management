class RawBibtexEntry < ActiveRecord::Base
  belongs_to :library
  belongs_to :reference
end
