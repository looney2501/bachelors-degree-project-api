# frozen_string_literal: true

class RemoveAvailableOverlappingPlanningsFromPlanningSessions < ActiveRecord::Migration[6.1]
  def change
    remove_column :planning_sessions, :available_overlapping_plannings
  end
end
