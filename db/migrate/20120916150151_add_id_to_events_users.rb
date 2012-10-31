class AddIdToEventsUsers < ActiveRecord::Migration
  def change
    add_column :events_users, :id, :primary_key
  end
end
