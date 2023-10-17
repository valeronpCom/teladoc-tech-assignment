# frozen_string_literal: true

class Doctor < ApplicationRecord
  has_many :working_hours
  has_many :appointments
end
