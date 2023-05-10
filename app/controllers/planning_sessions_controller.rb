# frozen_string_literal: true

class PlanningSessionsController < ApplicationController
  def create
    @planning_session = PlanningSession.create!(planning_session_params)

    @planning_session.free_days << generate_weekend_days
    @planning_session.free_days << generate_national_free_days

    render json: { message: 'Created!' }, status: :ok
  end

  private

  def planning_session_params
    params.require(:planning_session).permit(:year, :available_free_days)
  end

  def generate_weekend_days
    year = @planning_session.year
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    (start_date..end_date).map do |date|
      FreeDay.new(date: date, free_day_type: :weekend) if date.saturday? || date.sunday?
    end.compact
  end

  def generate_national_free_days
    year = @planning_session.year
    Holidays.between(Date.new(year, 1, 1), Date.new(year, 12, 31), :ro).map do |holiday|
      FreeDay.new(date: holiday[:date], free_day_type: :national)
    end
  end
end
