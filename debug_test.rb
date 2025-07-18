#!/usr/bin/env ruby

require_relative './config/environment'

# Clean up database
User.destroy_all
Device.destroy_all
DeviceAssignment.destroy_all

# Create user
user = User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')
serial_number = '123456'

puts "Created user: #{user.id}"

# Step 1: Assign device
puts "\nStep 1: Assigning device"
AssignDeviceToUser.new(
  requesting_user: user,
  serial_number: serial_number,
  new_device_owner_id: user.id
).call

device = Device.find_by(serial_number: serial_number)
puts "Device user_id: #{device.user_id}"

assignment = DeviceAssignment.find_by(serial_number: serial_number)
puts "Assignment: #{assignment.id}, returned_at: #{assignment.returned_at}"

# Step 2: Return device
puts "\nStep 2: Returning device"
ReturnDeviceFromUser.new(
  user: user,
  serial_number: serial_number,
  from_user: user.id
).call

device.reload
assignment.reload
puts "Device user_id after return: #{device.user_id}"
puts "Assignment returned_at after return: #{assignment.returned_at}"

# Step 3: Try to assign again
puts "\nStep 3: Trying to assign again"
begin
  AssignDeviceToUser.new(
    requesting_user: user,
    serial_number: serial_number,
    new_device_owner_id: user.id
  ).call
  puts "Assignment succeeded (should have failed)"
rescue AssigningError::AlreadyUsedOnUser
  puts "Assignment failed as expected with AlreadyUsedOnUser"
rescue => e
  puts "Assignment failed with unexpected error: #{e.class} - #{e.message}"
end

puts "\nAll assignments:"
DeviceAssignment.all.each do |a|
  puts "  ID: #{a.id}, user_id: #{a.user_id}, serial: #{a.serial_number}, returned_at: #{a.returned_at}"
end
