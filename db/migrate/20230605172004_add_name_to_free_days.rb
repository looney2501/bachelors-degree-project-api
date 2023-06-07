# frozen_string_literal: true

class AddNameToFreeDays < ActiveRecord::Migration[6.1]
  def change
    add_column :free_days, :name, :string
  end
end
