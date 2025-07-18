require 'rails_helper'

RSpec.describe 'Device Assignment Flow' do
  it 'prevents reassignment of returned device' do
    # Create user
    user = create(:user)
    serial_number = '123456'

    # First assignment
    service = AssignDeviceToUser.new(
      requesting_user: user,
      serial_number: serial_number,
      new_device_owner_id: user.id
    )
    service.call

    # Return device
    return_service = ReturnDeviceFromUser.new(
      user: user,
      serial_number: serial_number,
      from_user: user.id
    )
    return_service.call

    # Try to assign again - should fail
    expect {
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call
    }.to raise_error(AssigningError::AlreadyUsedOnUser)
  end
end
