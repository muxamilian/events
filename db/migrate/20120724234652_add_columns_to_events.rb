class AddColumnsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :address, :string
    add_column :events, :gmaps, :boolean
  end
end
