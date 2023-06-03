class AddStatusToPlanningSession < ActiveRecord::Migration[6.1]
  def change
    add_column :planning_sessions, :status, :string, default: :created
  end
end
