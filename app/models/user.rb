class User < ApplicationRecord
  has_many :api_keys, as: :bearer
  has_many :devices, dependent: :destroy
  has_many :device_assignments, dependent: :destroy
  has_secure_password
end
