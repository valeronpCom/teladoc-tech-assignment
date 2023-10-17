# app/controllers/appointments_controller.rb
class AppointmentsController < ApplicationController
  before_action :set_doctor

  # GET /doctors/:doctor_id/appointments
  def index
    @working_hours = @doctor.working_hours.find_by(day_of_week: Time.zone.now.wday)
    if @working_hours
      start_time = @working_hours.start_time
      end_time = @working_hours.end_time

      all_slots = calculate_time_slots(start_time, end_time, 30.minutes)

      booked_slots = @doctor.appointments.where(appointment_date: Date.today.beginning_of_day..Date.today.end_of_day).pluck(:appointment_date).map { |d| d.hour }
      free_slots = all_slots - booked_slots

      render json: {
        working_hours: "#{start_time.strftime('%H:%M')}:00 - #{end_time.strftime('%H:%M')}:00",
        available_slots: free_slots.map { |time| time.strftime('%H:%M') }
      }
    else
      render json: { error: "Doctor's working hours not defined for today." }, status: :not_found
    end
  end

  # POST /doctors/:doctor_id/appointments/create_slot
  def create
    requested_datetime = Time.zone.parse(appointment_params[:appointment_date])
    requested_time = round_to_nearest_30_minutes(requested_datetime)
    if free_slots.include?(requested_time.strftime('%H:%M'))
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

  # PATCH/PUT /doctors/:doctor_id/appointments/update_slot/:id
  def update
    @appointment = @doctor.appointments.find(params[:id])
    requested_datetime = Time.zone.parse(appointment_params[:appointment_date])
    requested_time = round_to_nearest_30_minutes(requested_datetime)
    if free_slots.include?(requested_time.strftime('%H:%M'))
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
    minutes = (time.min % 30) >= 15 ? 30 : 0
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

  def free_slots
    working_hours = @doctor.working_hours.find_by(day_of_week: Time.zone.now.wday)
    return [] unless working_hours

    start_time = working_hours.start_time
    end_time = working_hours.end_time

    all_slots = calculate_time_slots(start_time, end_time, 30.minutes)

    booked_slots = @doctor.appointments.where(appointment_date: Date.today.beginning_of_day..Date.today.end_of_day).pluck(:appointment_date).map { |d| d.hour }
    all_slots.map { |time| time.strftime('%H:%M') } - booked_slots.map { |hour| "#{hour}:00" }
  end
end
