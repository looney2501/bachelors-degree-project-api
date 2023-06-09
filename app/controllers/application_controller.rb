# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Serializable
  include ActiveStorage::SetCurrent

  protected

  def configure_permitted_parameters
    # for user account creation i.e sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:type])
  end
end
