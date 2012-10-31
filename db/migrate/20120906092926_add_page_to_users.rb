class AddPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :page, :string
  end
end
