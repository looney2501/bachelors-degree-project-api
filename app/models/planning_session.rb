# frozen_string_literal: true

class PlanningSession < ApplicationRecord
  include FreeDaysContainer

  has_many :restriction_intervals, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :vacations, dependent: :destroy

  # weekends + national free days
  def nonoverlapping_free_days
    nonoverlapping_free_days = national_free_days.to_a
    weekend_days.each do |wd|
      nonoverlapping_free_days << wd unless nonoverlapping_free_days.any? { |fd| fd.date == wd.date }
    end

    nonoverlapping_free_days
  end
end

# == Schema Information
#
# Table name: planning_sessions
#
#  id                  :bigint           not null, primary key
#  available_free_days :integer          not null
#  status              :string           default("created")
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_planning_sessions_on_year  (year) UNIQUE
#
