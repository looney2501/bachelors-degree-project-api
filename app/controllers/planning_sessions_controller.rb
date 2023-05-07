class PlanningSessionsController < ApplicationController
  def create
    @planning_session = PlanningSession.create!(planning_session_params)

    @planning_session.free_days << generate_weekend_days

    render json: { message: 'Created!' }, status: :ok
  end

  private

  def planning_session_params
    params.require(:planning_session).permit(:year, :available_free_days, :available_overlapping_plannings)
  end

  def generate_weekend_days
    year = @planning_session.year
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    (start_date..end_date).map do |date|
      FreeDay.new(date: date, free_day_type: :weekend) if date.saturday? || date.sunday?
    end.compact
  end
end
