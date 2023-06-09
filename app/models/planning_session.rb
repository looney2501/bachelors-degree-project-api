# frozen_string_literal: true

class PlanningSession < ApplicationRecord
  include FreeDaysContainer

  has_many :restriction_intervals, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :vacations, dependent: :destroy

  # weekends + national free days
  def nonoverlapping_free_days(start_date = Date.new(year, 1, 1), end_date = Date.new(year, 12, 31))
    nonoverlapping_free_days = national_free_days.where('date >= ? and date <= ?', start_date, end_date).to_a
    weekend_days.where('date >= ? and date <= ?', start_date, end_date).each do |wd|
      nonoverlapping_free_days << wd unless nonoverlapping_free_days.any? { |fd| fd.date == wd.date }
    end

    nonoverlapping_free_days
  end

  def count_days_not_free(start_date, end_date)
    total_days_number = (end_date - start_date).to_i + 1
    total_free_days = nonoverlapping_free_days(start_date, end_date).count
    total_days_number - total_free_days
  end

  def restriction_days
    restriction_days = []
    restriction_intervals.each do |restriction_interval|
      restriction_days.concat((restriction_interval.start_date..restriction_interval.end_date).to_a)
    end
    restriction_days
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
