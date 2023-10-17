# frozen_string_literal: true

FactoryBot.define do
  factory :working_hour do
    day_of_week { 1 } # Example: Monday
    start_time { '00:00' }
    end_time { '23:59' }
    doctor
  end
end
