# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Doctor.create!(name: "Dr. John Smith", specialty: "Cardiology")
Doctor.create!(name: "Dr. Jane Johnson", specialty: "Dermatology")
Doctor.create!(name: "Dr. Robert Brown", specialty: "Orthopedics")

Patient.create!(name: "John Doe", contact_info: "123-456-7890")
Patient.create!(name: "John John", contact_info: "234-567-8900")

doctor1 = Doctor.find_by!(name: "Dr. John Smith")
doctor2 = Doctor.find_by!(name: "Dr. Jane Johnson")

doctor1.working_hours.create!(day_of_week: 1, start_time: "09:00", end_time: "17:00")

doctor2.working_hours.create!(day_of_week: 2, start_time: "08:00", end_time: "16:00")
