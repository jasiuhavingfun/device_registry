class CreateDeviceAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :device_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true
      t.string :serial_number
      t.datetime :assigned_at
      t.datetime :returned_at

      t.timestamps
    end
  end
end
