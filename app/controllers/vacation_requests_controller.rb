# frozen_string_literal: true

class VacationRequestsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def create
    @vacation_request = VacationRequest.create!(vacation_request_params.merge({ user_id: current_user.id }))

    requested_intervals = params[:requested_intervals].map { |ri| RequestedInterval.new(requested_interval_params(ri)) }
    @vacation_request.requested_intervals << requested_intervals

    render json: { message: 'Created!' }, status: :ok
  end

  private

  def vacation_request_params
    params.require(:vacation_request).permit(:planning_session_id)
  end

  def requested_interval_params(ri)
    ri.permit(:start_date, :end_date, :importance_level)
  end
end
