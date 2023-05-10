# frozen_string_literal: true

class RestrictionInterval < ApplicationRecord
  belongs_to :planning_session
end

# == Schema Information
#
# Table name: restriction_intervals
#
#  id                              :bigint           not null, primary key
#  available_overlapping_plannings :integer
#  end_date                        :date             not null
#  start_date                      :date             not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  planning_session_id             :bigint
#
# Indexes
#
#  index_restriction_intervals_on_planning_session_id  (planning_session_id)
#
