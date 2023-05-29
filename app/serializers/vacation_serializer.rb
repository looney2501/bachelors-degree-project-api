# frozen_string_literal: true

class VacationSerializer < RootSerializer
  attributes :user, :free_days

  def user
    serialize(object.user, serializer: UserSerializer)
  end

  def free_days
    object.free_days.map(&:date)
  end
end

# == Schema Information
#
# Table name: vacations
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  planning_session_id :bigint
#  user_id             :bigint
#
# Indexes
#
#  index_vacations_on_planning_session_id              (planning_session_id)
#  index_vacations_on_user_id                          (user_id)
#  index_vacations_on_user_id_and_planning_session_id  (user_id,planning_session_id) UNIQUE
#
