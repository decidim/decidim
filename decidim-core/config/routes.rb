# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  mount Decidim::Api::Engine => "/api"

  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/sessions",
               confirmations: "decidim/devise/confirmations",
               registrations: "decidim/devise/registrations",
               passwords: "decidim/devise/passwords",
               omniauth_callbacks: "decidim/devise/omniauth_registrations"
             }

  devise_scope :user do
    post "omniauth_registrations" => "devise/omniauth_registrations#create"
  end

  resource :locale, only: [:create]

  Decidim.featurable_manifests.each do |manifest|
    mount manifest.engine, at: "/", as: "decidim_#{manifest.name}"
  end

  authenticate(:user) do
    resources :authorizations, only: [:new, :create, :index] do
      collection do
        get :first_login
      end
    end
    resource :account, only: [:show, :update, :destroy], controller: "account" do
      member do
        get :delete
      end
    end
    resource :notifications_settings, only: [:show, :update], controller: "notifications_settings"
    resources :own_user_groups, only: [:index]
  end

  resources :pages, only: [:index, :show], format: false

  get "/static_map", to: "static_map#show", as: :static_map
  get "/cookies/accept", to: "cookie_policy#accept", as: :accept_cookies

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  resource :report, only: [:create]

  root to: "pages#show", id: "home"
end
