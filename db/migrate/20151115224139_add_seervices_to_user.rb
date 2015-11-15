class AddSeervicesToUser < ActiveRecord::Migration
  def change
    add_column :users, :services, :text
    rename_column :users, :uid, :google_uid
  end
end
