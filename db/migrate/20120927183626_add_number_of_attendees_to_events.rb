class AddNumberOfAttendeesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :number_of_attendees, :integer, default: 0
  end
end
