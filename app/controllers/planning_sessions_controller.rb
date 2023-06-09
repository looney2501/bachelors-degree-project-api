# frozen_string_literal: true

class PlanningSessionsController < ApplicationController
  include Containers
  before_action :authenticate_user!
  authorize_resource

  def index
    case params['mode']
    when 'years'
      years = PlanningSession.order(year: :desc).pluck(:year)
      render json: { years: years }, status: :ok
    when 'by_year_thin_details'
      @planning_session = PlanningSession.find_by(year: params[:year])
      has_requested = @planning_session.vacation_requests.where(user_id: current_user.id).count.positive?
      render json: {
        planning_session: serialize(@planning_session, serializer: PlanningSessionThinSerializer),
        has_requested: has_requested
      }, status: :created
    when 'by_year_all_vacations'
      @planning_session = PlanningSession.find_by(year: params[:year])
      if @planning_session
        if current_user.type == 'Employee'
          render json: { planning_session: serialize(@planning_session, serializer: PlanningSessionEmployeeVacationSerializer, serializer_options: { user_id: current_user.id }) }, status: :ok
        else
          render json: { planning_session: serialize(@planning_session, serializer: PlanningSessionAllVacationsSerializer) }, status: :ok
        end
      else
        render json: { error: 'Planning Session Not Found!' }, status: :not_found
      end

    else
      render json: {}, status: :ok
    end
  end

  def create
    @planning_session = PlanningSession.create!(planning_session_params)

    restriction_intervals = params[:restriction_intervals].map { |ri| RestrictionInterval.new(restriction_interval_params(ri)) }
    @planning_session.restriction_intervals << restriction_intervals

    @planning_session.free_days << generate_weekend_days
    @planning_session.free_days << generate_national_free_days

    render json: { planning_session: serialize(@planning_session, serializer: PlanningSessionAllVacationsSerializer) }, status: :created
  end

  def generate_vacations_schedule
    @planning_session = PlanningSession.find(params[:id])
    @vacation_requests = @planning_session.vacation_requests
    @requests_queue = PriorityQueue.new
    @all_free_days = @planning_session.nonoverlapping_free_days.pluck(:date)
    @restriction_days = @planning_session.restriction_days

    @solution = []

    # loop do
    #   create_vacations_schedule
    #
    #   analyse_solution
    #
    #   prioritise_requests
    # end

    prioritise_requests

    create_vacations_schedule

    @solution.each(&:save)

    render json: { planning_session: serialize(@planning_session, serializer: PlanningSessionAllVacationsSerializer) }, status: :ok
  end

  private

  def prioritise_requests
    @vacation_requests.each do |vr|
      # atribuie scorul initial in coada de prioritati
      vr.score = vr.initial_score if vr.score.nil?

      @requests_queue.push(vr, vr.score)
    end
  end

  def create_vacations_schedule
    until @requests_queue.empty?
      request = @requests_queue.pop

      vacation = Vacation.new(planning_session_id: @planning_session.id, user_id: request.user_id)

      unconstrained_requested_days = (request.requested_days - @all_free_days) - @restriction_days
      vacation.prepared_free_days.concat(unconstrained_requested_days)

      @solution << vacation
    end
  end

  # def create_vacations_schedule
  #   year = @planning_session.year
  #
  #   until @requests_queue.empty?
  #     request = @requests_queue.pop
  #
  #     vacation = Vacation.create!(planning_session_id: request.planning_session_id, user_id: request.user_id)
  #     vacation_free_days = []
  #
  #     default_free_days = @planning_session.nonoverlapping_free_days
  #     total_free_days_no = default_free_days.length + @planning_session.available_free_days
  #     days_per_month = total_free_days_no / 12
  #
  #     # Add free days for every month
  #     12.times do |month_no|
  #       default_free_days_month = default_free_days.select { |dfd| dfd.date.month == month_no + 1 }
  #
  #       # Add default free days (national + weekend)
  #       vacation_free_days.concat(default_free_days_month.map do |dfd|
  #         FreeDay.new(date: dfd.date, free_day_type: dfd.free_day_type, free_days_container_type: 'Vacation', free_days_container_id: vacation.id)
  #       end)
  #       # Add rest of days
  #       remaining_days = days_per_month - default_free_days_month.length
  #       current_date = Date.new(year, month_no + 1, 1)
  #
  #       while remaining_days.positive?
  #         unless default_free_days_month.any? { |dfd| dfd.date == current_date }
  #           vacation_free_days << FreeDay.new(date: current_date, free_day_type: 'planned', free_days_container_type: 'Vacation', free_days_container_id: vacation.id)
  #           remaining_days -= 1
  #         end
  #         current_date = current_date.next_day
  #       end
  #     end
  #
  #     remaining_days_per_month = total_free_days_no - vacation_free_days.count
  #
  #     # Add remaining free days
  #     12.times do |month_no|
  #       break unless remaining_days_per_month.positive?
  #
  #       current_date = Date.new(year, month_no + 1, 1)
  #
  #       current_date = current_date.next_day while vacation_free_days.any? { |fd| fd.date == current_date }
  #
  #       vacation_free_days << FreeDay.new(date: current_date, free_day_type: 'planned', free_days_container_type: 'Vacation', free_days_container_id: vacation.id)
  #       remaining_days_per_month -= 1
  #     end
  #
  #     vacation_free_days.each(&:save)
  #
  #     @solution << vacation
  #   end
  # end

  def analyse_solution; end

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
      FreeDay.new(date: holiday[:date], free_day_type: :national, name: holiday[:name])
    end
  end
end
