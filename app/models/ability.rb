# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    can :manage, User
    can :manage, VacationRequest
    can %i[read update_planned_free_days], PlanningSession

    return unless user.type == 'Manager'

    can :manage, PlanningSession
  end
end
