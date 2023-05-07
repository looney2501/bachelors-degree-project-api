# frozen_string_literal: true

class CreatePlanningSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :planning_sessions do |t|
      t.integer :available_free_days, null: false
      t.integer :year, null: false, index: true, unique: true
      t.integer :available_overlapping_plannifications, null: false

      t.timestamps
    end
  end
end
