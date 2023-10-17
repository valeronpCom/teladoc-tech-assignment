# frozen_string_literal: true

class DoctorsController < ApplicationController
  before_action :set_doctor, only: [:show]

  # GET /doctors
  def index
    @doctors = Doctor.all
    render json: @doctors
  end

  # GET /doctors/:id
  def show
    render json: @doctor
  end

  private

  def set_doctor
    @doctor = Doctor.find(params[:id])
  end
end
