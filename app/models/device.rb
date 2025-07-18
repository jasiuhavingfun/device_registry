class Device < ApplicationRecord
  belongs_to :user, optional: true
  has_many :device_assignments, dependent: :destroy
  
  validates :serial_number, presence: true, uniqueness: true
end
