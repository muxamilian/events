class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :descr
      t.datetime :time
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
