# frozen_string_literal: true

class CreateVacationRequest < ActiveRecord::Migration[6.1]
  def change
    create_table :vacation_requests do |t|
      t.references :user, foreign_key: true
      t.references :planning_session, foreign_key: true

      t.index %i[planning_session_id user_id], unique: true

      t.timestamps
    end
  end
end
