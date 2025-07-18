# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    device = Device.find_by(serial_number: serial_number)
    return unless device

    Device.transaction do
      device.update!(user_id: nil)
      
      assignment = DeviceAssignment.active.find_by(
        user_id: from_user,
        device: device,
        serial_number: serial_number
      )
      
      assignment&.update!(returned_at: Time.current)
    end
  end

  private

  attr_reader :user, :serial_number, :from_user
end
