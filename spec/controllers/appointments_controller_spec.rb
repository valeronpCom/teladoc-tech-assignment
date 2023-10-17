# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do
  describe 'GET #index' do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor, day_of_week: Date.today.wday) }

    before do
      [doctor, working_hour]
    end

    it 'returns a doctor\'s available hours and free slots' do
      get :index, params: { doctor_id: doctor.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:working_hours)).to_not be_nil
    end
  end

  describe 'POST #create_slot' do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor, day_of_week: Date.today.wday) }
    let(:patient) { create(:patient) }
    let(:appointment2) { create(:appointment, appointment_date: "2023-10-17T12:00:00", doctor: doctor, patient_id: patient.id) }

    before do
      [doctor, working_hour, patient, appointment2]
    end

    it 'creates a new appointment within available slots' do
      post :create, params: { doctor_id: doctor.id, appointment: { appointment_date: DateTime.now + 1.hour, patient_id: patient.id } }
      expect(response).to have_http_status(:created)
    end

    it 'should lead to an error' do
      post :create, params: { doctor_id: doctor.id, appointment: { appointment_date: "2023-10-17T12:00:00", patient_id: patient.id } }
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
