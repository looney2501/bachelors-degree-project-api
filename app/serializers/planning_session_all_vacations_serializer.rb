# frozen_string_literal: true

class PlanningSessionAllVacationsSerializer < RootSerializer
  attributes :id, :national_free_days, :year, :vacations, :status, :restriction_intervals

  def user_id
    instance_options[:serializer_options][:user_id] if instance_options[:serializer_options]
  end

  def national_free_days
    serialize(object.national_free_days, each_serializer: FreeDaySerializer)
  end

  def vacations
    vacations = user_id ? object.vacations.where(user_id: user_id) : object.vacations
    serialize(vacations, each_serializer: VacationSerializer)
  end

  def restriction_intervals
    serialize(object.restriction_intervals, each_serializer: RestrictionIntervalSerializer)
  end
end
