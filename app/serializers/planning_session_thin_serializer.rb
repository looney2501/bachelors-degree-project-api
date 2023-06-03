# frozen_string_literal: true

class PlanningSessionThinSerializer < RootSerializer
  attributes :id, :national_free_days, :year, :status

  def national_free_days
    serialize(object.national_free_days, each_serializer: FreeDaySerializer)
  end
end
