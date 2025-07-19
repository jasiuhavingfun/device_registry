# frozen_string_literal: true

FactoryBot.define do
  factory :device_assignment do
    user
    device
    serial_number { device&.serial_number || "SERIAL#{rand(100000..999999)}" }
    assigned_at { Time.current }
    returned_at { nil }

    trait :returned do
      returned_at { 1.hour.ago }
    end
  end
end
