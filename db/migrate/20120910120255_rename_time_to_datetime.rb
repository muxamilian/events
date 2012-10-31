class RenameTimeToDatetime < ActiveRecord::Migration
  change_table :events do |t|
    t.rename :time, :datetime
  end
end
