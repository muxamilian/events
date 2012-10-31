class RenameLonToLng < ActiveRecord::Migration
  change_table :events do |t|
    t.rename :lon, :lng
  end
end
