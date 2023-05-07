# frozen_string_literal: true

class CreateFreeDays < ActiveRecord::Migration[6.1]
  def change
    create_table :free_days do |t|
      t.date :date
      t.string :type
      t.references :free_days_container, polymorphic: true, index: true, null: false

      t.timestamps
    end
  end
end
