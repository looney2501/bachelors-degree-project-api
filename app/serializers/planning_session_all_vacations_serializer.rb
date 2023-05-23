# frozen_string_literal: true

class PlanningSessionAllVacationsSerializer < RootSerializer
  attributes :id, :available_free_days, :year, :default_free_days, :vacations

  def default_free_days
    serialize(object.nonoverlapping_free_days, each_serializer: FreeDaySerializer)
  end

  def vacations
    serialize(object.vacations, each_serializer: VacationSerializer)
  end
end
