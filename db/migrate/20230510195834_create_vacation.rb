# frozen_string_literal: true

class CreateVacation < ActiveRecord::Migration[6.1]
  def change
    create_table :vacations do |t|
      t.references :user
      t.references :planning_session

      t.index %i[user_id planning_session_id], unique: true

      t.timestamps
    end
  end
end
