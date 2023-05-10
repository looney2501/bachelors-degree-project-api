# frozen_string_literal: true

class CreateIntervals < ActiveRecord::Migration[6.1]
  def change
    create_table :intervals do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :available_overlapping_plannings
      t.integer :requested_days
      t.string :type, null: false
      t.references :planning_session, index: true, null: true

      t.timestamps
    end
  end
end
