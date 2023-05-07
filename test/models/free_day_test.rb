# frozen_string_literal: true

require 'test_helper'

class FreeDayTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: free_days
#
#  id                       :bigint           not null, primary key
#  date                     :date
#  free_days_container_type :string           not null
#  type                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  free_days_container_id   :bigint           not null
#
# Indexes
#
#  index_free_days_on_free_days_container  (free_days_container_type,free_days_container_id)
#
