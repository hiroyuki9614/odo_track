# frozen_string_literal: true

Rails.application.routes.draw do
  get 'pages/top'
  get 'pages/help'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # daily_logsのルーティング
  get '/daily_logs/show/:id', to: 'daily_logs#show', as: 'daily_logs_show'
  delete '/daily_logs/:id', to: 'daily_logs#destroy', as: 'daily_logs_destroy'
  resources :daily_logs, except: %i[show delete] do
    collection do
      post :confirm
      get :confirm
      get :keywd # 既に存在する場合はこの行は不要
      post :keywd_process
    end
    member do
      patch :edit_confirm
      get :edit_confirm
    end
  end
  # get 'users/signup', to: 'users/new', as: ':users_signup'
  # get '/users/show/:id', to: 'users#show', as: 'users_show'
  delete '/users/:id', to: 'users#destroy', as: 'user_destroy'
  get    '/signup', to: 'users#new'
  resources :users, except: %i[delete new] do
    collection do
      post :confirm
      get :confirm
    end
    member do
      patch :edit_confirm
      get :edit_confirm
    end
  end
end
