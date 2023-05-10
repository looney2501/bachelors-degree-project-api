# frozen_string_literal: true

class VacationRequestsController < ApplicationController
  def create
    @vacation_request = VacationRequest.create!(vacation_request_params.merge(user: current_user))

    @vacation_request.free_days << (params[:start_date]..params[:end_date]).map do |d|
      FreeDay.new(date: d, free_day_type: :requested)
    end

    render json: { message: 'Created!' }, status: :ok
  end

  private

  def vacation_request_params
    params.require(:vacation_request).permit(:planning_session_id)
  end
end
