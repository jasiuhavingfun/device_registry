# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    sequence(:serial_number) { |n| "DEVICE#{n.to_s.rjust(6, '0')}" }
    user { nil }

    trait :assigned do
      user
    end
  end
end
