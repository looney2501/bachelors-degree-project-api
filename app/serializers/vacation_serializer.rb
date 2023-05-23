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
