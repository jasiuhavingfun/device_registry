class DeviceAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :device
  
  validates :serial_number, presence: true
  validates :assigned_at, presence: true
  
  scope :returned, -> { where.not(returned_at: nil) }
  scope :active, -> { where(returned_at: nil) }
end
