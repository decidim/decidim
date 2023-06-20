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

  devise_for :user_groups,
             class_name: "Decidim::UserGroup",
             module: :devise,
             router_name: :decidim,
             controllers: {
               confirmations: "decidim/devise/confirmations"
             }

  devise_scope :user do
    post "omniauth_registrations" => "devise/omniauth_registrations#create"
  end

  resource :manifest, only: [:show]

  resource :locale, only: [:create]

  Decidim.participatory_space_manifests.each do |manifest|
    mount manifest.context(:public).engine, at: "/", as: "decidim_#{manifest.name}"
  end

  mount Decidim::Verifications::Engine, at: "/", as: "decidim_verifications"
  mount Decidim::Comments::Engine, at: "/", as: "decidim_comments"

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
    resources :own_user_groups, only: [:index]

    get "/newsletters_opt_in/:token", to: "newsletters_opt_in#update", as: :newsletters_opt_in

    resource :download_your_data, only: [:show], controller: "download_your_data" do
      member do
        post :export
        get :download_file
      end
    end

    resources :notifications_subscriptions, param: :auth, only: [:create, :destroy]
    resource :user_interests, only: [:show, :update]

    get "/authorization_modals/:authorization_action/f/:component_id(/:resource_name/:resource_id)", to: "authorization_modals#show", as: :authorization_modal
    get(
      "/free_resource_authorization_modals/:authorization_action/f/:resource_name/:resource_id",
      to: "free_resource_authorization_modals#show",
      as: :free_resource_authorization_modal
    )

    resources :groups, except: [:destroy, :index, :show] do
      resources :join_requests, only: [:create, :update, :destroy], controller: "user_group_join_requests"
      resources :invites, only: [:index, :create, :update, :destroy], controller: "group_invites"
      resources :users, only: [:destroy], controller: "group_members", as: "manage_users" do
        member do
          post :promote
        end
        member do
          post :demote
        end
      end
      resource :email_confirmation, only: [:create], controller: "group_email_confirmations"

      member do
        delete :leave
      end
    end
  end

  resources :profiles, only: [:show], param: :nickname, constraints: { nickname: %r{[^/]+} }, format: false
  scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^/]+} } do
    get "following", to: "profiles#following", as: "profile_following"
    get "followers", to: "profiles#followers", as: "profile_followers"
    get "badges", to: "profiles#badges", as: "profile_badges"
    get "groups", to: "profiles#groups", as: "profile_groups"
    get "members", to: "profiles#members", as: "profile_members"
    get "group_members", to: "profiles#group_members", as: "profile_group_members"
    get "group_admins", to: "profiles#group_admins", as: "profile_group_admins"
    get "activity", to: "user_activities#index", as: "profile_activity"
    resources :conversations, except: [:destroy], controller: "user_conversations", as: "profile_conversations"
  end

  scope :timeouts do
    post "heartbeat", to: "timeouts#heartbeat"
    get "seconds_until_timeout", to: "timeouts#seconds_until_timeout"
  end

  resources :pages, only: [:index, :show], format: false

  get "/search", to: "searches#index", as: :search

  get "/link", to: "links#new", as: :link

  get "/scopes/picker", to: "scopes#picker", as: :scopes_picker

  get "/static_map", to: "static_map#show", as: :static_map
  put "/pages/terms-of-service/accept", to: "tos#accept_tos", as: :accept_tos

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  get "/open-data/download", to: "open_data#download", as: :open_data_download

  resource :follow, only: [:create, :destroy]
  resource :report, only: [:create]
  resource :report_user, only: [:create]
  resources :endorsements, only: [:create, :destroy] do
    get :identities, on: :member
  end
  resources :amends, only: [:new, :reject, :accept], controller: :amendments do
    collection do
      post :create
    end
    member do
      get :compare_draft
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
