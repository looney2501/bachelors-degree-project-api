# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    can :manage, VacationRequest
    can :read, PlanningSession

    return unless user.type == 'Manager'

    can :manage, PlanningSession
  end
end
