# frozen_string_literal: true

Rails.application.routes.draw do
  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"

  resource  :password, only: [:edit, :update]
  resources :sessions, only: [:index, :show, :destroy]

  namespace :admin do
    resources :festivals do
      resources :editions do
        get :search_for_film_to_add, to: "films#search_for_film_to_add_to_edition"

        resources :selections, only: [:index, :new, :create] do
          get :csv, on: :collection
          post :import, on: :collection

          resources :ratings, only: [:index, :new, :create]
        end
      end
    end

    namespace :films do
      get :search
      get :add_country
      get :remove_country
    end

    resource :invitation, only: [:new, :create]

    namespace :critics do
      resource :invitation, only: [:new, :create]
      resources :ratings, only: [:index]
    end
  end

  namespace :sessions do
    resource :passwordless, only: [:new, :edit, :create]
  end

  namespace :identity do
    resource :email,              only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset,     only: [:new, :edit, :create, :update]
  end

  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
