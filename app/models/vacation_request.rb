# frozen_string_literal: true

class VacationRequest < ApplicationRecord
  include FreeDaysContainer

  belongs_to :user
  belongs_to :planning_session
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
