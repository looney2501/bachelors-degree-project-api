# frozen_string_literal: true

class Vacation < ApplicationRecord
  include FreeDaysContainer

  belongs_to :user
  belongs_to :planning_session

  after_save :save_prepared_free_days

  attr_accessor :prepared_free_days, :score

  def initialize(attributes = {}, _options = {})
    super(attributes)
    @prepared_free_days = []
  end

  def save_prepared_free_days
    return if prepared_free_days.blank?

    prepared_free_days.each { |free_day_date| FreeDay.create!(date: free_day_date, free_day_type: :planned, free_days_container_type: 'Vacation', free_days_container_id: id) }
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
