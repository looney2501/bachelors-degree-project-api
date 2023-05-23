# frozen_string_literal: true

module Serializable
  extend ActiveSupport::Concern

  def serialize(resource, options)
    ActiveModelSerializers::SerializableResource.new(
      resource,
      options
    ).serializable_hash
  end
end
