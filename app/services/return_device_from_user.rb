# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @requesting_user = user
    @serial_number = serial_number
    @from_user_id = from_user
  end

  def call
    validate_authorization!
    
    device = Device.find_by(serial_number: serial_number)
    return unless device

    Device.transaction do
      device.update!(user_id: nil)
      
      assignment = DeviceAssignment.active.find_by(
        user_id: from_user_id,
        device: device,
        serial_number: serial_number
      )
      
      assignment&.update!(returned_at: Time.current)
    end
  end

  private

  attr_reader :requesting_user, :serial_number, :from_user_id

  def validate_authorization!
    # Only the user who assigned the device can return it
    unless requesting_user.id == from_user_id
      raise RegistrationError::Unauthorized
    end
  end
end
