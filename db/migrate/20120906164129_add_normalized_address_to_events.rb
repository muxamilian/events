class AddNormalizedAddressToEvents < ActiveRecord::Migration
  def change
    add_column :events, :normalized_address, :string
  end
end
