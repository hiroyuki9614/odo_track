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
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # daily_logsのルーティング
  get '/daily_logs/show/:id', to: 'daily_logs#show', as: 'daily_logs_show'
  # delete '/daily_logs/:id', to: 'daily_logs#destroy', as: 'daily_logs_destroy'
  get '/daily_log/delete/:id', to: 'daily_logs#destroy'
  patch '/daily_log/delete/:id', to: 'daily_logs#destroy', as: 'daily_log_delete'
  resources :daily_logs, except: %i[show delete] do
    collection do
      post :confirm
      get :confirm
      get :frequent_destinations
    end
    member do
      patch :edit_confirm
      get :edit_confirm
    end
  end
  # get 'users/signup', to: 'users/new', as: ':users_signup'
  # get '/users/show/:id', to: 'users#show', as: 'users_show'
  # get '/users/delete/:id', to: 'users#logical_delete', as: 'user_delete'
  # patch '/users/delete/:id', to: 'users#logical_delete', as: 'user_delete'
  resources :users do
    # collection do
    #   post :confirm
    #   get :confirm
    # end
    # member do
    #   patch :user_delete
    #   get :user_delete
    #   patch :user_undelete
    #   get :user_undelete
    # end
  end
  resource :backup_settings, only: %i[edit update] # バックアップ設定
  delete '/admin/:id', to: 'admins#destroy', as: 'admin_user_destroy'
  get '/admin/delete/:id', to: 'admins#user_delete', as: 'get_admin_user_delete'
  patch '/admin/delete/:id', to: 'admins#user_delete', as: 'admin_user_delete'
  get '/admin/undelete/:id', to: 'admins#user_undelete', as: 'get_admin_user_undelete'
  patch '/admin/undelete/:id', to: 'admins#user_undelete', as: 'admin_user_undelete'
  delete '/admin/daily_log/:id', to: 'admins#daily_log_destroy', as: 'daily_log_destroy'
  get 'admin/discarded_daily_logs/', to: 'admins#discarded_daily_logs_index', as: 'discarded_daily_logs'
  # get 'admin/user_index', to: 'admins#index', as: 'admin_users_list'
  get 'admin/user_retired_index', to: 'admins#discarded_index', as: 'admin_users_retired_list'
  resources :admins do
    collection do
      # get :discarded_index
      #   post :confirm
      #   get :confirm
    end
  end
  get '/management_vehicle/delete/:id', to: 'management_vehicles#delete'
  patch '/management_vehicle/delete/:id', to: 'management_vehicles#delete', as: 'management_vehicle_delete'
  get '/management_vehicle/undelete/:id', to: 'management_vehicles#undelete'
  patch '/management_vehicle/undelete/:id', to: 'management_vehicles#undelete', as: 'management_vehicle_undelete'
  resources :management_vehicles do
    collection do
      post :confirm
      get :confirm
    end
    member do
      patch :edit_confirm
      get :edit_confirm
    end
  end
  resources :frequent_destinations, only: %i[create destroy]
  resources :export_daily_logs, only: [] do
    collection do
      get :download_index # ダウンロード可能なファイルの一覧を表示
      get :create_spreadsheet
      post :create_spreadsheet  # スプレッドシートの作成
      post :export_to_pdf       # PDFへのエクスポート
    end
  end
end
