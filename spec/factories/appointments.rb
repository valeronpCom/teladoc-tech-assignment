# frozen_string_literal: true

FactoryBot.define do
  factory :appointment do
    appointment_date { DateTime.now + 1.hour }
    doctor
    patient
  end
end
