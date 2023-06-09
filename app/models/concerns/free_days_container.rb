# frozen_string_literal: true

module FreeDaysContainer
  extend ActiveSupport::Concern

  included do
    has_many :free_days, as: :free_days_container, dependent: :destroy
    has_many :weekend_days,
             -> { weekend },
             class_name: 'FreeDay',
             as: :free_days_container,
             dependent: :destroy,
             foreign_key: :free_days_container_id
    has_many :national_free_days,
             -> { national },
             class_name: 'FreeDay',
             as: :free_days_container,
             dependent: :destroy,
             foreign_key: :free_days_container_id
    has_many :planned_free_days,
             -> { planned },
             class_name: 'FreeDay',
             as: :free_days_container,
             dependent: :destroy,
             foreign_key: :free_days_container_id
  end
end
