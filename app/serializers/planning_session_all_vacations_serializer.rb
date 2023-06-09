# frozen_string_literal: true

class PlanningSessionAllVacationsSerializer < RootSerializer
  attributes :id, :national_free_days, :year, :vacations, :status, :restriction_intervals, :available_free_days

  def national_free_days
    serialize(object.national_free_days, each_serializer: FreeDaySerializer)
  end

  def vacations
    serialize(object.vacations, each_serializer: VacationSerializer)
  end

  def restriction_intervals
    serialize(object.restriction_intervals, each_serializer: RestrictionIntervalSerializer)
  end
end
