# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]
  def assign
    AssignDeviceToUser.new(
      requesting_user: @current_user,
      serial_number: device_params[:serial_number],
      new_device_owner_id: params[:new_owner_id].to_i
    ).call
    
    head :ok
  rescue RegistrationError::Unauthorized
    render json: { error: 'Unauthorized' }, status: :unprocessable_entity
  rescue AssigningError::AlreadyUsedOnUser
    render json: { error: 'Device already used by this user' }, status: :unprocessable_entity
  rescue AssigningError::AlreadyUsedOnOtherUser
    render json: { error: 'Device already assigned to another user' }, status: :unprocessable_entity
  end

  def unassign
    ReturnDeviceFromUser.new(
      user: @current_user,
      serial_number: device_params[:serial_number],
      from_user: @current_user.id
    ).call
    
    head :ok
  rescue RegistrationError::Unauthorized
    render json: { error: 'Unauthorized' }, status: :unprocessable_entity
  end

  private

  def device_params
    params.require(:device).permit(:serial_number)
  end
end
