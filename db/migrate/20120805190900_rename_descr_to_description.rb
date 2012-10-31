class RenameDescrToDescription < ActiveRecord::Migration
  change_table :events do |t|
    t.rename :descr, :description
  end
end
