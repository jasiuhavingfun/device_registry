# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id
  end

  def call
    validate_authorization!
    validate_device_availability!
    validate_previous_usage!
    
    assign_device!
  end

  private

  attr_reader :requesting_user, :serial_number, :new_device_owner_id

  def validate_authorization!
    unless requesting_user.id == new_device_owner_id
      raise RegistrationError::Unauthorized
    end
  end

  def validate_device_availability!
    if device.user_id.present? && device.user_id != new_device_owner_id
      raise AssigningError::AlreadyUsedOnOtherUser
    end
  end

  def validate_previous_usage!
    if previously_returned_by_user?
      raise AssigningError::AlreadyUsedOnUser
    end
  end

  def assign_device!
    Device.transaction do
      device.update!(user_id: new_device_owner_id)
      
      DeviceAssignment.create!(
        user_id: new_device_owner_id,
        device: device,
        serial_number: serial_number,
        assigned_at: Time.current
      )
    end
  end

  def device
    @device ||= Device.find_or_create_by(serial_number: serial_number)
  end

  def previously_returned_by_user?
    DeviceAssignment.returned.exists?(
      user_id: new_device_owner_id,
      serial_number: serial_number
    )
  end
end
