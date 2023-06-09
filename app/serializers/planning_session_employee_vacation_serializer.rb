# frozen_string_literal: true

class PlanningSessionEmployeeVacationSerializer < RootSerializer
  attributes :id, :national_free_days, :year, :vacations, :status, :requested_intervals, :available_free_days

  def user_id
    instance_options[:serializer_options][:user_id] if instance_options[:serializer_options]
  end

  def national_free_days
    serialize(object.national_free_days, each_serializer: FreeDaySerializer)
  end

  def vacations
    vacations = object.vacations.where(user_id: user_id)
    serialize(vacations, each_serializer: VacationSerializer)
  end

  def requested_intervals
    vacation_request = object.vacation_requests.find_by(user_id: user_id)

    return [] if vacation_request.blank?

    serialize(vacation_request.requested_intervals, each_serializer: RequestedIntervalSerializer)
  end
end
