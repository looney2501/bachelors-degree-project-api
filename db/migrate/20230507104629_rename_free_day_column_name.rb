class RenameFreeDayColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :free_days, :type, :free_day_type
  end
end
