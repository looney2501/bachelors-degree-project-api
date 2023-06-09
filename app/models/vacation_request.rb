# frozen_string_literal: true

class VacationRequest < ApplicationRecord
  include FreeDaysContainer

  belongs_to :user
  belongs_to :planning_session

  has_many :requested_intervals, dependent: :destroy

  attr_accessor :score

  def initial_score
    requested_intervals.reduce(1) do |total_score, requested_interval|
      interval_score = requested_interval.importance_level * requested_interval.count_days_not_free

      total_score + interval_score
    end
  end

  def requested_days
    requested_days = []
    requested_intervals.each do |requested_interval|
      requested_days << {
        days: (requested_interval.start_date..requested_interval.end_date).to_a,
        importance_level: requested_interval.importance_level
      }
    end
    requested_days
  end
end

# == Schema Information
#
# Table name: vacation_requests
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  planning_session_id :bigint
#  user_id             :bigint
#
# Indexes
#
#  index_vacation_requests_on_planning_session_id              (planning_session_id)
#  index_vacation_requests_on_planning_session_id_and_user_id  (planning_session_id,user_id) UNIQUE
#  index_vacation_requests_on_user_id                          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_session_id => planning_sessions.id)
#  fk_rails_...  (user_id => users.id)
#
