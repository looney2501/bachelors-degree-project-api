# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def update
    @user.update(user_params)
    @user.avatar.attach(params[:avatar])

    render json: { user: serialize(@user, serializer: UserSerializer) }, status: :ok
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :role, :phone_number)
  end
end
