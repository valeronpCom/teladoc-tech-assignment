# frozen_string_literal: true

FactoryBot.define do
  factory :patient do
    name { 'John Doe' }
    contact_info { '123-456-7890' } # Example contact information
    # Add other attributes as needed
  end
end
