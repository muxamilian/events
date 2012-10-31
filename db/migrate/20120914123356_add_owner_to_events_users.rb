class AddOwnerToEventsUsers < ActiveRecord::Migration
  def change
    add_column :events_users, :owner, :boolean, :default => false
  end
end
