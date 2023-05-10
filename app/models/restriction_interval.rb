# frozen_string_literal: true

class RestrictionInterval < Interval
  belongs_to :planning_session
end

# == Schema Information
#
# Table name: intervals
#
#  id                              :bigint           not null, primary key
#  available_overlapping_plannings :integer
#  end_date                        :date             not null
#  requested_days                  :integer
#  start_date                      :date             not null
#  type                            :string           not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  planning_session_id             :bigint
#
# Indexes
#
#  index_intervals_on_planning_session_id  (planning_session_id)
#
