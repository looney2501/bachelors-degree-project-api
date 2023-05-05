# frozen_string_literal: true

class VacationsController < ApplicationController
  def initialize_scheduling_session
    required_params = params.permit(:year)

    generate_weekend_days(required_params[:year])

    render json: { message: 'Created!' }, status: :ok
  end

  private

  def generate_weekend_days(year)
    if ActiveRecord::Base.connection.table_exists?(:weekend_days)
      puts 'Truncating weekend_days table'
      ActiveRecord::Base.connection.execute('TRUNCATE TABLE weekend_days;')
    else
      puts 'Creating weekend_days table'
      ActiveRecord::Base.connection.create_table(:weekend_days) do |t|
        t.date :day
      end
    end

    # Generate and insert weekend days for current year
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    (start_date..end_date).each do |date|
      ActiveRecord::Base.connection.execute("INSERT INTO weekend_days (day) VALUES ('#{date.to_s(:db)}')") if date.saturday? || date.sunday?
    end
  end
end
