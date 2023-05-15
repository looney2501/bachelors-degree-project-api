# frozen_string_literal: true

class Vacation < ApplicationRecord
  include FreeDaysContainer

  belongs_to :user
  belongs_to :planning_session
end
