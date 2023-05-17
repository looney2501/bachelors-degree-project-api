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

    # loop do
    #   create_vacations_schedule
    #
    #   analyse_solution
    #
    #   prioritise_requests
    # end

    create_vacations_schedule

    render json: { vacations: @solution }, status: :ok
  end

  private

  def create_vacations_schedule
    monthly_free_days = @planning_session.monthly_free_days
    year = @planning_session.year

    until @requests_queue.empty?
      request = @requests_queue.pop

      vacation = Vacation.create!(planning_session_id: request.planning_session_id, user_id: request.user_id)

      # Add free days for every month
      12.times do |month_no|
        vacation.planned_free_days << begin
          start_date = Date.new(year, month_no + 1, 1).beginning_of_month

          (start_date..start_date + (monthly_free_days[:min_days_months][:no_days] - 1)).map do |date|
            FreeDay.new(date: date, free_day_type: 'planned')
          end
        end
      end

      # Add remainder free days
      monthly_free_days[:max_days_months][:no_months].times do |month_no|
        vacation.planned_free_days << FreeDay.new(
          date: Date.new(year, month_no + 1, monthly_free_days[:max_days_months][:no_days]),
          free_day_type: 'planned'
        )
      end

      @solution << vacation
    end
  end

  def analyse_solution; end

  def prioritise_requests; end

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
