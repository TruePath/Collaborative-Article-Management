class AddUserIdToLibraries < ActiveRecord::Migration
  def change
    add_reference :libraries, :user, index: true, foreign_key: true
  end
end
