# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  mount Decidim::Api::Engine => "/api"

  get "/offline", to: "offline#show"

  get "/favicon.ico", to: "favicon#show"

  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/sessions",
               confirmations: "decidim/devise/confirmations",
               passwords: "decidim/devise/passwords",
               unlocks: "decidim/devise/unlocks",
               omniauth_callbacks: "decidim/devise/omniauth_registrations"
             },
             skip: [:registrations]

  # Manually define the registration routes because otherwise the default "edit"
  # route would be exposed through Devise while we already have the edit and
  # destroy routes available through the account pages.
  resource(
    :registration,
    only: [:new, :create],
    as: :user_registration,
    path: "/users",
    path_names: { new: "sign_up" },
    controller: "devise/registrations"
  ) do
    # The "cancel" route forces the session data which is usually expired after
    # sign in to be expired now. This is useful if the user wants to cancel
    # OAuth signing in/up in the middle of the process, removing all OAuth
    # session data. @see [Devise::RegistrationsController#cancel]
    get :cancel
  end

  devise_scope :user do
    post "omniauth_registrations" => "devise/omniauth_registrations#create"
  end

  resource :manifest, only: [:show]

  resource :locale, only: [:create]

  post :locate, to: "geolocation#locate"

  Decidim.global_engines.each do |name, engine_data|
    mount engine_data[:engine], at: engine_data[:at], as: name
  end

  authenticate(:user) do
    devise_scope :user do
      get "change_password" => "devise/passwords"
      put "apply_password" => "devise/passwords"
    end

    resource :account, only: [:show, :update, :destroy], controller: "account" do
      member do
        get :delete
        post :resend_confirmation_instructions
        post :cancel_email_change
      end
    end
    resources :conversations, only: [:new, :create, :index, :show, :update], controller: "messaging/conversations"
    post "/conversations/check_multiple", to: "messaging/conversations#check_multiple"
    resources :notifications, only: [:index, :destroy] do
      collection do
        delete :read_all
      end
    end
    resource :notifications_settings, only: [:show, :update], controller: "notifications_settings"

    get "/newsletters_opt_in/:token", to: "newsletters_opt_in#update", as: :newsletters_opt_in

    resource :download_your_data, only: [:show], controller: "download_your_data" do
      member do
        post :export
        get "/:uuid", to: "download_your_data#download_file", as: :download
      end
    end

    resources :notifications_subscriptions, param: :auth, only: [:create, :destroy]

    get "/authorization_modals/:authorization_action/f/:component_id(/:resource_name/:resource_id)", to: "authorization_modals#show", as: :authorization_modal
    get(
      "/free_resource_authorization_modals/:authorization_action/f/:resource_name/:resource_id",
      to: "free_resource_authorization_modals#show",
      as: :free_resource_authorization_modal
    )
  end

  resources :profiles, only: [:show], param: :nickname, constraints: { nickname: %r{[^/]+} }, format: false
  scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^/]+} } do
    get "following", to: "profiles#following", as: "profile_following"
    get "followers", to: "profiles#followers", as: "profile_followers"
    get "badges", to: "profiles#badges", as: "profile_badges"
    get "activity", to: "user_activities#index", as: "profile_activity"
  end

  scope :timeouts do
    post "heartbeat", to: "timeouts#heartbeat"
    get "seconds_until_timeout", to: "timeouts#seconds_until_timeout"
  end

  resources :pages, only: [:index, :show], format: false

  get "/search", to: "searches#index", as: :search
  get "/resource_autocomplete", to: "resource_autocomplete#index", as: :resource_autocomplete

  get "/link", to: "links#new", as: :link
  get "/qr-code", to: "qr#show", as: :qr

  get "/static_map", to: "static_map#show", as: :static_map
  put "/pages/terms-of-service/accept", to: "tos#accept_tos", as: :accept_tos

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  get "/open-data", to: "open_data#index", as: :open_data
  get "/open-data/download", to: "open_data#download", as: :open_data_download
  get "/open-data/download/:resource", to: "open_data#download", as: :open_data_download_resource

  resource :follow, only: [:create, :destroy]
  resource :report, only: [:create]
  resource :report_user, only: [:create]
  resources :endorsements, only: [:create, :destroy]
  resources :amends, only: [:new, :reject, :accept], controller: :amendments do
    collection do
      post :create
    end
    member do
      get :edit_draft
      patch :update_draft
      delete :destroy_draft
      get :preview_draft
      post :publish_draft
      patch :reject
      post :promote
      get :review
      patch :accept
      put :withdraw
    end
  end

  resources :editor_images, only: [:create]

  namespace :gamification do
    resources :badges, only: [:index]
  end

  resources :newsletters, only: [:show] do
    get :unsubscribe, on: :collection
  end

  resources :upload_validations, only: [:create]

  resources :last_activities, only: [:index]

  resources :short_links, only: [:index, :show], path: "s"

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  scope :oauth do
    get "/me" => "doorkeeper/credentials#me"
  end

  root to: "homepage#show"
end
