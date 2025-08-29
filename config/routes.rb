# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  get  "sign-in", to: "sessions#new"
  post "sign-in", to: "sessions#create"
  delete  "sign-out", to: "sessions#destroy"

  get "magic", to: "sessions/passwordlesses#new"
  post "magic", to: "sessions/passwordlesses#create"
  get  "verify", to: "sessions/passwordlesses#edit"

  resources :critics, only: [:show]
  resources :editions, only: [:show] do
    get :live, on: :member
    resource :summary, only: [:show]
    resource :share, only: [] do
      get :overview, to: "shares#overview", defaults: { format: "png" }, format: true
      get :summary, to: "shares#summary", defaults: { format: "png" }, format: true
      get "stat/:template", to: "shares#stat", defaults: { format: "png" }, format: true
    end
  end
  resources :films, only: [:show]
  resource :password, only: [:edit, :update]
  resources :podcasts, only: [:index, :show] do
    resources :episodes, controller: "podcasts/episodes", only: [:show]
  end
  resources :ratings, only: [:show]
  resource :session, only: [:destroy]

  namespace :admin do
    root "festivals#index"

    resources :festivals do
      resources :editions do
        get :search_for_film_to_add, to: "films#search_for_film_to_add_to_edition"

        resources :attendances, only: [:index, :create, :edit, :update, :destroy]

        resources :categories, only: [:index, :update] do
          patch :reorder, on: :member
        end

        resources :selections do
          get :csv, on: :collection
          post :import, on: :collection

          resources :ratings, only: [:new, :create, :edit, :update, :destroy]
        end
      end
    end

    namespace :films do
      get :search
      get :add_country
      get :remove_country
    end

    resource :invitation, only: [:new, :create]

    resources :critics, only: [:edit, :update]

    namespace :critics do
      resource :invitation, only: [:new, :create]
    end

    resources :podcasts do
      resources :episodes, controller: "podcasts/episodes" do
        post :webhook, on: :collection
      end
    end

    resources :users, only: [:index, :destroy] do
      collection do
        get :critics
        get :admins
      end
    end
  end

  namespace :identity do
    resource :email,              only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset,     only: [:new, :edit, :create, :update]
  end

  namespace :sessions do
    resource :passwordless, only: [:new, :edit, :create]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
end
