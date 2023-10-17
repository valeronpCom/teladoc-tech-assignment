# frozen_string_literal: true

require 'rails_helper'

describe AppointmentsController do
  describe 'GET #index' do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor, day_of_week: Date.today.wday) }
    let(:day_of_week) { 2 }

    before do
      [doctor, working_hour]
    end

    it 'returns a doctor\'s available hours and free slots' do
      get :index, params: { doctor_id: doctor.id, day_of_week: day_of_week }
      expect(response).to have_http_status(:success)
      expect(assigns(:working_hours)).to_not be_nil
    end
  end

  describe 'POST #create_slot' do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor, day_of_week: Date.today.wday) }
    let(:working_hour2) { create(:working_hour, doctor: doctor, day_of_week: (DateTime.now + 1.day + 1.week).wday) }
    let(:patient) { create(:patient) }
    let(:appointment2) do
      create(:appointment, appointment_date: Time.current.change(hour: 12, min: 0, sec: 0).strftime('%Y-%m-%dT%H:%M:%S'), doctor: doctor,
                           patient_id: patient.id)
    end

    before do
      [doctor, working_hour, working_hour2, patient, appointment2]
    end

    it 'creates a new appointment within available slots' do
      post :create, params: { doctor_id: doctor.id, appointment: { appointment_date: DateTime.now + 1.hour, patient_id: patient.id } }
      expect(response).to have_http_status(:created)
    end

    it 'creates a new appointment within available slots at next week + 1 day' do
      post :create, params: { doctor_id: doctor.id, appointment: { appointment_date: DateTime.now + 1.day + 1.week, patient_id: patient.id } }
      expect(response).to have_http_status(:created)
    end

    it 'should lead to an error' do
      post :create,
           params: { doctor_id: doctor.id,
                     appointment: { appointment_date: Time.current.change(hour: 12, min: 0, sec: 0).strftime('%Y-%m-%dT%H:%M:%S'),
                                    patient_id: patient.id } }
      expect(JSON.parse(response.body)['error']).to eq("Requested time slot is not available")
    end
  end

  describe 'PATCH #update_slot' do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor, day_of_week: Date.today.wday) }
    let(:appointment) { create(:appointment, doctor: doctor) }
    let(:patient) { create(:patient) }

    before do
      [doctor, working_hour, appointment, patient]
    end

    it 'updates an appointment within available slots' do
      patch :update,
            params: { doctor_id: doctor.id, id: appointment.id, appointment: { appointment_date: DateTime.now + 2.hours, patient_id: patient.id } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE #destroy' do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor, day_of_week: Date.today.wday) }
    let(:appointment) { create(:appointment, doctor: doctor) }

    before do
      [doctor, working_hour, appointment]
    end

    it 'destroys an appointment' do
      delete :destroy, params: { doctor_id: doctor.id, id: appointment.id }
      expect(response).to have_http_status(:no_content)
      expect { Appointment.find(appointment.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
