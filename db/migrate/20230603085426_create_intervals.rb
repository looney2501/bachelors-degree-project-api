# frozen_string_literal: true

class CreateIntervals < ActiveRecord::Migration[6.1]
  def change
    create_table :intervals do |t|
      t.date :start_date
      t.date :end_date
      t.string :type
      t.integer :importance_level
      t.integer :available_overlapping_plannings
      t.references :planning_session
      t.references :vacation_request

      t.timestamps
    end
  end
end
