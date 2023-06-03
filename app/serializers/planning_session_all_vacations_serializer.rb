# frozen_string_literal: true

class PlanningSessionAllVacationsSerializer < RootSerializer
  attributes :id, :national_free_days, :year, :vacations, :status

  def national_free_days
    serialize(object.national_free_days, each_serializer: FreeDaySerializer)
  end

  def vacations
    serialize(object.vacations, each_serializer: VacationSerializer)
  end
end
