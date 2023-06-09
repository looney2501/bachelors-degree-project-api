# frozen_string_literal: true

class RequestedInterval < Interval
  belongs_to :vacation_request
  delegate :planning_session, to: :vacation_request

  def count_days_not_free
    planning_session.count_days_not_free(start_date, end_date)
  end
end

# == Schema Information
#
# Table name: intervals
#
#  id                              :bigint           not null, primary key
#  available_overlapping_plannings :integer
#  end_date                        :date
#  importance_level                :integer
#  start_date                      :date
#  type                            :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  planning_session_id             :bigint
#  vacation_request_id             :bigint
#
# Indexes
#
#  index_intervals_on_planning_session_id  (planning_session_id)
#  index_intervals_on_vacation_request_id  (vacation_request_id)
#
