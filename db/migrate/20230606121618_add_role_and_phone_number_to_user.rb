# frozen_string_literal: true

class AddRoleAndPhoneNumberToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :role, :string
    add_column :users, :phone_number, :string
  end
end
