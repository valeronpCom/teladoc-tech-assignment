# frozen_string_literal: true

class AppointmentsController < ApplicationController
  before_action :set_doctor

  # GET /doctors/:doctor_id/appointments?day_of_week=number_of_the_day
  def index
    @working_hours = @doctor.working_hours.find_by(day_of_week: params[:day_of_week])
    beginning_of_day, end_of_day = confirm_date(params[:day_of_week])
    if @working_hours
      start_time = @working_hours.start_time
      end_time = @working_hours.end_time

      all_slots = calculate_time_slots(start_time, end_time, 30.minutes)
      all_slots_formatted = all_slots.map { |time| time.strftime('%H:%M') }

      booked_slots = @doctor.appointments.where(appointment_date: beginning_of_day..end_of_day).pluck(:appointment_date).map do |d|
        d.strftime('%H:%M')
      end
      free_slots = all_slots_formatted - booked_slots

      render json: {
        working_hours: "#{start_time.strftime('%H:%M')}:00 - #{end_time.strftime('%H:%M')}:00",
        available_slots: free_slots
      }
    else
      render json: { error: "Doctor's working hours not defined for today." }, status: :not_found
    end
  end

  # POST /doctors/:doctor_id/appointments/create
  def create
    day_of_week = Time.zone.parse(appointment_params[:appointment_date]).wday
    requested_datetime = Time.zone.parse(appointment_params[:appointment_date])
    requested_time = round_to_nearest_30_minutes(requested_datetime)
    if free_slots(day_of_week).include?(requested_time.strftime('%H:%M'))
      @appointment = @doctor.appointments.new(appointment_params)
      if @appointment.save
        render json: @appointment, status: :created
      else
        render json: @appointment.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "Requested time slot is not available" }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /doctors/:doctor_id/appointments/update/:id
  def update
    @appointment = @doctor.appointments.find(params[:id])
    day_of_week = Time.zone.parse(appointment_params[:appointment_date]).wday
    requested_datetime = Time.zone.parse(appointment_params[:appointment_date])
    requested_time = round_to_nearest_30_minutes(requested_datetime)
    if free_slots(day_of_week).include?(requested_time.strftime('%H:%M'))
      if @appointment.update(appointment_params)
        render json: @appointment
      else
        render json: @appointment.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "Requested time slot is not available" }, status: :unprocessable_entity
    end
  end

  # DELETE /doctors/:doctor_id/appointments/:id
  def destroy
    @appointment = @doctor.appointments.find(params[:id])
    @appointment.destroy
  end

  private

  def set_doctor
    @doctor = Doctor.find(params[:doctor_id])
  end

  def appointment_params
    params.require(:appointment).permit(:appointment_date, :patient_id)
  end

  def round_to_nearest_30_minutes(time)
    minutes = time.min
    if minutes < 15
      minutes = 0
    elsif minutes < 45
      minutes = 30
    else
      minutes = 0
      time = time.advance(hours: 1)
    end
    time.change(min: minutes, sec: 0)
  end

  def calculate_time_slots(start_time, end_time, interval)
    current_time = start_time
    slots = []

    while current_time < end_time
      slots << current_time
      current_time += interval
    end

    slots
  end

  def confirm_date(day_of_week)
    day_of_the_week = day_of_week.to_i
    today = Date.today
    days_until_target_day = today.wday - day_of_the_week
    target_date = today - days_until_target_day.days

    beginning_of_day = target_date.beginning_of_day
    end_of_day = target_date.end_of_day
    [beginning_of_day, end_of_day]
  end

  def free_slots(day_of_week)
    working_hours = @doctor.working_hours.find_by(day_of_week: day_of_week)
    beginning_of_day, end_of_day = confirm_date(day_of_week)
    return [] unless working_hours

    start_time = working_hours.start_time
    end_time = working_hours.end_time

    all_slots = calculate_time_slots(start_time, end_time, 30.minutes)
    all_slots_formatted = all_slots.map { |time| time.strftime('%H:%M') }

    booked_slots = @doctor.appointments.where(appointment_date: beginning_of_day..end_of_day).pluck(:appointment_date).map do |d|
      d.strftime('%H:%M')
    end
    all_slots_formatted - booked_slots
  end
end
