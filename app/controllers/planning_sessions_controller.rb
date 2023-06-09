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
    @vacation_requests = @planning_session.vacation_requests.to_a
    @requests_queue = PriorityQueue.new
    @all_free_days = @planning_session.nonoverlapping_free_days.pluck(:date)
    @all_solutions = []

    loop do
      prioritise_requests
      create_vacations_schedule
      analyse_solution

      current_solution_order = @current_solution[:vacations].map(&:user_id)
      all_solutions_order = []
      @all_solutions.each do |solution|
        all_solutions_order << solution[:vacations].map(&:user_id)
      end

      break if @current_solution[:score].zero?

      if current_solution_order.in?(all_solutions_order)
        best_solution = @all_solutions.min_by { |solution| solution[:score] }
        @current_solution = best_solution

        break
      end

      @all_solutions << @current_solution
    end

    @current_solution[:vacations].each(&:save)

    render json: { planning_session: serialize(@planning_session, serializer: PlanningSessionAllVacationsSerializer) }, status: :ok
  end

  def update_planned_free_days
    vacation = Vacation.find_by(user_id: params['user_id'], planning_session_id: params['planning_session_id'])

    new_days = params['free_days']
    old_days = vacation.planned_free_days.pluck(:date)

    days_to_remove = old_days - new_days
    vacation.planned_free_days.where(date: days_to_remove).destroy_all

    days_to_add = new_days - old_days
    days_to_add.each { |date| vacation.free_days.create(date: date, free_day_type: :planned) }

    render json: { planning_session: serialize(vacation.planning_session, serializer: PlanningSessionEmployeeVacationSerializer, serializer_options: { user_id: current_user.id }) }, status: :ok
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
    @current_solution = { vacations: [], score: 0 }

    restriction_intervals_days = @planning_session.restriction_days
    restriction_days = restriction_intervals_days.reduce([]) do |arr, ri|
      arr.concat(ri[:days])
    end

    until @requests_queue.empty?
      request = @requests_queue.pop
      user_id = request.user_id
      requested_days_intervals = request.requested_days
      vacation = Vacation.new(planning_session_id: @planning_session.id, user_id: request.user_id)

      requested_days_intervals.each do |request_interval|
        ## Avoid weekends and national free days
        request_interval[:days] -= @all_free_days

        ## Add unconstrained requested days
        unmatching_days = request_interval[:days] - restriction_days
        vacation.prepared_free_days.concat(unmatching_days)

        request_interval[:days] -= unmatching_days
      end

      ## Add constrained requests if restriction interval permits
      restriction_intervals_days.each do |restriction_interval|
        includes_user = restriction_interval[:users_ids].include?(user_id)

        next if restriction_interval[:available_plannings].zero? && !includes_user

        requested_days_intervals.each do |request_interval|
          matching_days = request_interval[:days] & restriction_interval[:days]

          vacation.prepared_free_days.concat(matching_days)
          request_interval[:days] -= matching_days

          if matching_days.present? && !includes_user
            restriction_interval[:available_plannings] -= 1
            restriction_interval[:users_ids] << user_id
          end
        end
      end

      ## Shift constrained requests if restriction interval no longer permits
      score = 0
      requested_days_intervals.each do |request_interval|
        request_interval[:days].each do |day|
          planned_day = day - 1
          found = false
          until found
            planned_day += 1
            planned_day = planned_day.prev_year if planned_day.year != day.year

            next if @all_free_days.include?(planned_day) || vacation.prepared_free_days.include?(planned_day)

            containing_restriction_interval = restriction_intervals_days.find do |restriction_interval|
              restriction_interval[:days].include?(planned_day)
            end

            includes_user = containing_restriction_interval.present? && containing_restriction_interval[:users_ids]&.include?(user_id)
            next if containing_restriction_interval.present? && containing_restriction_interval[:available_plannings].zero? && !includes_user

            found = true

            if containing_restriction_interval.present? && !includes_user
              containing_restriction_interval[:available_plannings] -= 1
              containing_restriction_interval[:users_ids] << user_id
            end
          end
          vacation.prepared_free_days << planned_day

          score += (planned_day - day).to_i.abs * request_interval[:importance_level]
        end
      end
      vacation.score = score

      ## Add remaining days
      remaining_days_no = @planning_session.available_free_days - vacation.prepared_free_days.length
      total_free_days_no = @all_free_days.count + @planning_session.available_free_days
      free_days_per_month = total_free_days_no / 12
      free_days_per_month += 1 if (total_free_days_no % 12).positive?
      remaining_plannable_days_no = 0

      ## Add remaining days in order to keep the months balanced
      12.times do |month|
        planned_days = vacation.prepared_free_days.filter { |day| day.month == month + 1 }
        default_free_days = @all_free_days.filter { |day| day.month == month + 1 }
        remaining_plannable_days_no = free_days_per_month + remaining_plannable_days_no - (planned_days.count + default_free_days.count)
        month_changed = false

        date = Date.new(@planning_session.year, month + 1, 1)
        while !month_changed && remaining_plannable_days_no.positive? && remaining_days_no.positive?
          already_planned = planned_days.include?(date) || default_free_days.include?(date)

          containing_restriction_interval = restriction_intervals_days.find do |restriction_interval|
            restriction_interval[:days].include?(date)
          end

          includes_user = containing_restriction_interval.present? && containing_restriction_interval[:users_ids].include?(user_id)

          unless already_planned || (containing_restriction_interval.present? && containing_restriction_interval[:available_plannings].zero? && !includes_user)
            vacation.prepared_free_days << date
            remaining_plannable_days_no -= 1
            remaining_days_no -= 1

            if containing_restriction_interval.present? && !includes_user
              containing_restriction_interval[:available_plannings] -= 1
              containing_restriction_interval[:users_ids] << user_id
            end
          end

          date += 1
          month_changed = true if date.month != month + 1
        end

        break if remaining_days_no.zero?
      end

      @current_solution[:vacations] << vacation
    end
  end

  def analyse_solution
    total_score = 0
    @current_solution[:vacations].each do |vacation|
      total_score += vacation.score
      request = @vacation_requests.find { |request| request.user_id == vacation.user_id }
      request.score = vacation.score
    end
    @current_solution[:score] = total_score
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
      FreeDay.new(date: holiday[:date], free_day_type: :national, name: holiday[:name])
    end
  end
end
