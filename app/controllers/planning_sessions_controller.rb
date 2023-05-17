# frozen_string_literal: true

class PlanningSessionsController < ApplicationController
  include Containers

  def create
    @planning_session = PlanningSession.create!(planning_session_params)

    restriction_intervals = params[:restriction_intervals].map { |ri| RestrictionInterval.new(restriction_interval_params(ri)) }
    @planning_session.restriction_intervals << restriction_intervals

    @planning_session.free_days << generate_weekend_days
    @planning_session.free_days << generate_national_free_days

    render json: { message: 'Created!' }, status: :ok
  end

  def generate_vacations_schedule
    @planning_session = PlanningSession.find(params[:id])

    @requests_queue = PriorityQueue.new

    @planning_session.vacation_requests.each do |vr|
      @requests_queue.push(vr, 1)
    end

    @solution = []

    loop do
      create_vacations_schedule

      analyse_solution

      prioritise_requests
    end

  end

  private

  def create_vacations_schedule
    @requests_queue.each do |r|
      # Assign free days at the beginning of every month

    end
  end

  def analyse_solution

  end

  def prioritise_requests

  end

  def planning_session_params
    params.require(:planning_session).permit(:year, :available_free_days)
  end

  def restriction_interval_params(ri)
    ri.permit(:start_date, :end_date, :available_overlapping_plannings)
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
