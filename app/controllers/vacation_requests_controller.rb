# frozen_string_literal: true

class VacationRequestsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def create
    @vacation_request = VacationRequest.create!(vacation_request_params.merge({ user_id: current_user.id }))

    params[:intervals].length.times do |i|
      @vacation_request.free_days << (params[:intervals][i][:start_date]..params[:intervals][i][:end_date]).map do |d|
        FreeDay.new(date: d, free_day_type: :requested)
      end
    end

    render json: { message: 'Created!' }, status: :ok
  end

  private

  def vacation_request_params
    params.require(:vacation_request).permit(:planning_session_id)
  end
end
