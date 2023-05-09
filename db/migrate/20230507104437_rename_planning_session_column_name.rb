# frozen_string_literal: true

class RenamePlanningSessionColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :planning_sessions, :available_overlapping_plannifications, :available_overlapping_plannings
  end
end
