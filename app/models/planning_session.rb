# frozen_string_literal: true

class PlanningSession < ApplicationRecord
  include FreeDaysContainer

  has_many :restriction_intervals, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :vacations, dependent: :destroy

  def monthly_free_days
    total_free_days = (nonoverlapping_free_days.length + available_free_days)

    quotient = total_free_days / 12
    remainder = total_free_days % 12

    months_with_quotient = 0
    months_with_remainder = 0

    12.times do |month|
      if month < remainder
        months_with_remainder += 1
      else
        months_with_quotient += 1
      end
    end

    {
      min_days_months: {
        no_days: quotient,
        no_months: months_with_quotient
      },
      max_days_months: {
        no_days: quotient + 1,
        no_months: months_with_remainder
      }
    }
  end

  private

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
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_planning_sessions_on_year  (year)
#
