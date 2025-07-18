# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    sequence(:serial_number) { |n| "device_#{n}" }
    user { nil }
  end
end
