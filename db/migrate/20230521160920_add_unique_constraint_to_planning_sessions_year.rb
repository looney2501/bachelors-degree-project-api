# frozen_string_literal: true

class AddUniqueConstraintToPlanningSessionsYear < ActiveRecord::Migration[6.1]
  def change
    remove_index :planning_sessions, name: 'index_planning_sessions_on_year'
    add_index :planning_sessions, :year, unique: true
  end
end
