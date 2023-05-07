# frozen_string_literal: true

class CreatePlanningSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :planning_sessions do |t|
      t.integer :available_free_days
      t.integer :year
      t.integer :available_overlapping_plannifications

      t.timestamps
    end
  end
end
