# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: 'auth',
                     path_names: { sign_in: 'login',
                                   sign_out: 'logout',
                                   password: 'secret',
                                   confirmation: 'verification',
                                   registration: 'register',
                                   sign_up: 'cmon_let_me_in' }
  devise_scope :user do
    get 'users/:id/edit' => 'users/registrations#edit',
        as: :edit_other_user_registration
    match 'users/:id', to: 'users/registrations#update', via: %i[patch put],
                       as: :other_user_registration
  end
  root to: 'pages#top'
  get 'pages/top'
  get 'pages/help'
  get 'pages/print'

  # APIのルーティング
  patch 'api/management_vehicles/undelete/:id', to: 'api/management_vehicles#undelete'
  patch 'api/management_vehicles/delete/:id', to: 'api/management_vehicles#destroy'
  patch 'api/users_for_admin/undelete/:id', to: 'api/users_for_admin#undelete'
  patch 'api/users_for_admin/delete/:id', to: 'api/users_for_admin#delete'
  patch 'api/daily_logs_for_admin/undelete/:id', to: 'api/daily_logs_for_admin#undelete'
  patch 'api/daily_logs_for_admin/delete/:id', to: 'api/daily_logs_for_admin#delete'
  namespace :api do
    resources :daily_logs
    resources :management_vehicles
    resources :users_for_admin
    resources :daily_logs_for_admin
    resources :favorite_vehicles
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get 'downloads', to: 'downloads#index'
  get 'downloads/:filename', to: 'downloads#show', as: :download

  # get '/daily_logs', to: 'daily_logs#index', as: :daily_logs
  resources :daily_logs_for_admin, only: %i[index]

  resources :users

  resources :daily_logs

  resources :users_for_admin

  resources :management_vehicles, only: %i[index]

  # resources :frequent_destinations, only: %i[create destroy]

  get 'export_daily_logs/export_pdf', to: 'export_daily_logs#export_pdf', as: :export_pdf
  resources :export_daily_logs
  # collection do
  #   post :export_to_pdf       # PDFへのエクスポート
  # end

  resources :favorite_vehicles, only: %i[new create destroy]
end
