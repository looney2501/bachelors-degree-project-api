# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :planning_sessions, only: %i[create index] do
    post :generate_vacations_schedule, on: :member
    get :all_vacations_by_year, on: :collection
  end
  resources :vacation_requests, only: %i[create]
  resources :users, only: %i[update]
end
