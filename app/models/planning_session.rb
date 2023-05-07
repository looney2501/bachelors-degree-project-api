# frozen_string_literal: true

class PlanningSession < ApplicationRecord
end

# == Schema Information
#
# Table name: planning_sessions
#
#  id                                    :bigint           not null, primary key
#  available_free_days                   :integer
#  available_overlapping_plannifications :integer
#  year                                  :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
