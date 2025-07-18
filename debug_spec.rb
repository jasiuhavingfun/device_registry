require 'rails_helper'

RSpec.describe AssignDeviceToUser do
  subject(:assign_device) do
    described_class.new(
      requesting_user: user,
      serial_number: serial_number,
      new_device_owner_id: new_device_owner_id
    ).call
  end

  let(:user) { create(:user) }
  let(:serial_number) { '123456' }
  let(:new_device_owner_id) { user.id }

  context 'when a user tries to register a device that was already assigned to and returned by the same user' do
    before do
      puts "Before block - assigning device first time"
      assign_device
      puts "Device assigned. Now returning it."
      ReturnDeviceFromUser.new(user: user, serial_number: serial_number, from_user: user.id).call
      puts "Device returned. Checking assignments:"
      DeviceAssignment.all.each do |a|
        puts "  Assignment: #{a.id}, user: #{a.user_id}, serial: #{a.serial_number}, returned_at: #{a.returned_at}"
      end
    end

    it 'does not allow to register' do
      puts "In test - trying to assign device again"
      expect { assign_device }.to raise_error(AssigningError::AlreadyUsedOnUser)
    end
  end
end
