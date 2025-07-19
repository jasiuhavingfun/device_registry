# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  subject(:return_device) do
    described_class.new(
      user: requesting_user,
      serial_number: serial_number,
      from_user: device_owner_id
    ).call
  end

  let(:device_owner) { create(:user) }
  let(:requesting_user) { device_owner }
  let(:device_owner_id) { device_owner.id }
  let(:serial_number) { '123456' }
  let(:device) { create(:device, serial_number: serial_number, user: device_owner) }

  before do
    # Create an active assignment for the device
    create(:device_assignment, 
           user: device_owner, 
           device: device, 
           serial_number: serial_number,
           assigned_at: 1.hour.ago,
           returned_at: nil)
  end

  context 'when user returns their own device' do
    it 'unassigns the device from the user' do
      expect { return_device }.to change { device.reload.user_id }.from(device_owner.id).to(nil)
    end

    it 'marks the device assignment as returned' do
      expect { return_device }.to change { 
        DeviceAssignment.find_by(serial_number: serial_number).returned_at 
      }.from(nil).to(be_within(1.second).of(Time.current))
    end

    it 'does not create a new device assignment' do
      expect { return_device }.not_to change { DeviceAssignment.count }
    end
  end

  context 'when user tries to return a device they do not own' do
    let(:other_user) { create(:user) }
    let(:requesting_user) { other_user }

    it 'raises an error' do
      expect { return_device }.to raise_error(RegistrationError::Unauthorized)
    end

    it 'does not change the device assignment' do
      expect { 
        begin
          return_device
        rescue RegistrationError::Unauthorized
          # Expected error
        end
      }.not_to change { device.reload.user_id }
    end
  end

  context 'when user tries to return a device that does not exist' do
    let(:serial_number) { 'nonexistent' }

    it 'does not raise an error' do
      expect { return_device }.not_to raise_error
    end

    it 'does not affect any device assignments' do
      expect { return_device }.not_to change { DeviceAssignment.count }
    end
  end

  context 'when user tries to return a device that is not assigned to anyone' do
    let(:unassigned_serial) { 'unassigned123' }

    before do
      # Create an unassigned device with a different serial number
      create(:device, serial_number: unassigned_serial, user: nil)
    end

    it 'does not raise an error' do
      expect { 
        described_class.new(
          user: requesting_user,
          serial_number: unassigned_serial,
          from_user: device_owner_id
        ).call
      }.not_to raise_error
    end

    it 'does not create any device assignments' do
      expect { 
        described_class.new(
          user: requesting_user,
          serial_number: unassigned_serial,
          from_user: device_owner_id
        ).call
      }.not_to change { DeviceAssignment.count }
    end
  end

  context 'when user tries to return a device that was already returned' do
    let(:returned_assignment) do
      create(:device_assignment,
             user: device_owner,
             device: device,
             serial_number: serial_number,
             assigned_at: 2.hours.ago,
             returned_at: 1.hour.ago)
    end

    before do
      # Clear the active assignment created in the main before block
      DeviceAssignment.destroy_all
      # Create a returned assignment
      returned_assignment
      # Make sure device is unassigned
      device.update!(user: nil)
    end

    it 'does not raise an error' do
      expect { return_device }.not_to raise_error
    end

    it 'does not change the device assignment' do
      expect { return_device }.not_to change { returned_assignment.reload.returned_at }
    end

    it 'device remains unassigned' do
      expect { return_device }.not_to change { device.reload.user_id }
    end
  end

  context 'when the requesting user is different from the device owner' do
    let(:other_user) { create(:user) }
    let(:requesting_user) { other_user }
    let(:device_owner_id) { device_owner.id }

    it 'raises an unauthorized error' do
      expect { return_device }.to raise_error(RegistrationError::Unauthorized)
    end
  end
end
