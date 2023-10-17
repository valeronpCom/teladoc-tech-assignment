# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DoctorsController, type: :controller do
  describe 'GET #index' do
    it 'returns a list of doctors' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:doctors)).to_not be_nil
    end
  end

  describe 'GET #show' do
    let(:doctor) { create(:doctor) }

    it 'returns the doctor details' do
      get :show, params: { id: doctor.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:doctor)).to eq(doctor)
    end
  end
end
