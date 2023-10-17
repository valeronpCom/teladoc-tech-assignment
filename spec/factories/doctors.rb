# frozen_string_literal: true

FactoryBot.define do
  factory :doctor do
    name { 'Dr. John Smith' }
    specialty { 'Cardiology' }
  end
end
