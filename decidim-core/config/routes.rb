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

  Decidim.participatory_space_manifests.each do |manifest|
    mount manifest.context(:public).engine, at: "/", as: "decidim_#{manifest.name}"
  end

  mount Decidim::Verifications::Engine, at: "/", as: "decidim_verifications"

  Decidim.global_engines.each do |name, engine_data|
    mount engine_data[:engine], at: engine_data[:at], as: name
  end

  authenticate(:user) do
    resource :account, only: [:show, :update, :destroy], controller: "account" do
      member do
        get :delete
      end
      resources :invitations, only: [:index, :create]
    end
    resources :conversations, only: [:new, :create, :index, :show, :update], controller: "messaging/conversations"
    resources :notifications, only: [:index, :destroy] do
      collection do
        delete :read_all
      end
    end
    resource :notifications_settings, only: [:show, :update], controller: "notifications_settings"
    resources :own_user_groups, only: [:index]

    get "/newsletters_opt_in/:token", to: "newsletters_opt_in#update", as: :newsletters_opt_in

    resource :data_portability, only: [:show], controller: "data_portability" do
      member do
        post :export
        get :download_file
      end
    end

    get "/authorization_modals/:authorization_action/f/:component_id(/:resource_name/:resource_id)", to: "authorization_modals#show", as: :authorization_modal
  end

  resources :profiles, only: [:show], param: :nickname, constraints: { nickname: %r{[^\/]+} }, format: false
  scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^\/]+} } do
    get "following", to: "profiles#following", as: "profile_following"
    get "followers", to: "profiles#followers", as: "profile_followers"
    get "badges", to: "profiles#badges", as: "profile_badges"
  end

  resources :pages, only: [:index, :show], format: false

  get "/search", to: "searches#index", as: :search

  get :organization_users, to: "users#index"

  get "/scopes/picker", to: "scopes#picker", as: :scopes_picker

  get "/static_map", to: "static_map#show", as: :static_map
  get "/cookies/accept", to: "cookie_policy#accept", as: :accept_cookies
  put "/pages/terms-and-conditions/accept", to: "tos#accept_tos", as: :accept_tos

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  resource :follow, only: [:create, :destroy]
  resource :report, only: [:create]

  resources :newsletters, only: [:show] do
    get :unsubscribe, on: :collection
  end

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  scope :oauth do
    get "/me" => "doorkeeper/credentials#me"
  end

  root to: "pages#show", id: "home"
end
