# frozen_string_literal: true

require 'test_helper'

class PlanningSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
