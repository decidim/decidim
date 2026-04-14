# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  extend Decidim::Routes::LocaleRedirects

  mount Decidim::Api::Engine => "/api"

  get "/", to: redirect { |params, request|
    locale_redirect(params, request, "/")
  }, as: :root_redirect

  get "/offline", to: "offline#show"

  get "/favicon.ico", to: "favicon#show"

  get "/admin", to: redirect { |params, request|
    locale_redirect(params, request, "/admin")
  }

  get "/admin/*rest", to: redirect { |params, request|
    locale_redirect(params, request, "/admin/#{params[:rest]}")
  }

  resource :manifest, only: [:show]

  resource :locale, only: [:create]

  post :locate, to: "geolocation#locate"

  Decidim.global_engines.each do |name, engine_data|
    mount engine_data[:engine], at: engine_data[:at], as: name
  end

  authenticate(:user) do
    scope "/:locale", defaults: { locale: Decidim.default_locale } do
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
    end

    scope "/:locale", defaults: { locale: Decidim.default_locale } do
      resource :download_your_data, only: [:show], controller: "download_your_data" do
        member do
          post :export
          get "/:uuid", to: "download_your_data#download_file", as: :download
        end
      end
    end

    resources :conversations, only: [:new, :create, :index, :show, :update], controller: "messaging/conversations"
    post "/conversations/check_multiple", to: "messaging/conversations#check_multiple"
    scope "/:locale", defaults: { locale: Decidim.default_locale } do
      resources :notifications, only: [:index, :destroy] do
        collection do
          delete :read_all
        end
      end
    end
    resource :notifications_settings, only: [:show, :update], controller: "notifications_settings"

    get "/newsletters_opt_in/:token", to: "newsletters_opt_in#update", as: :newsletters_opt_in

    get "/download_your_data", to: redirect(&locale_redirector("/download_your_data"))
    get "/download_your_data/:uuid", to: redirect { |params, request| locale_redirector("/download_your_data/#{params[:uuid]}").call(params, request) }

    resources :notifications_subscriptions, param: :auth, only: [:create, :destroy]

    get "/authorization_modals/:authorization_action/f/:component_id(/:resource_name/:resource_id)", to: "authorization_modals#show", as: :authorization_modal
    get(
      "/free_resource_authorization_modals/:authorization_action/f/:resource_name/:resource_id",
      to: "free_resource_authorization_modals#show",
      as: :free_resource_authorization_modal
    )

    get "/account/*rest", to: redirect(&locale_redirector("/account"))

    get "/account", to: redirect(&locale_redirector("/account"))
  end

  scope :timeouts do
    post "heartbeat", to: "timeouts#heartbeat"
    get "seconds_until_timeout", to: "timeouts#seconds_until_timeout"
  end

  # OmniAuth callbacks must be defined outside any dynamic segment scope
  # because Devise does not support scoping them under /:locale.
  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               omniauth_callbacks: "decidim/devise/omniauth_registrations"
             },
             only: :omniauth_callbacks

  scope "/:locale", constraints: { locale: Regexp.union(I18n.available_locales.map(&:to_s)) }, defaults: { locale: Decidim.default_locale } do
    devise_for :users,
               class_name: "Decidim::User",
               module: :devise,
               router_name: :decidim,
               controllers: {
                 invitations: "decidim/devise/invitations",
                 sessions: "decidim/devise/sessions",
                 confirmations: "decidim/devise/confirmations",
                 passwords: "decidim/devise/passwords",
                 unlocks: "decidim/devise/unlocks"
               },
               skip: [:registrations, :omniauth_callbacks]

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

    resources :pages, only: [:index, :show], format: false

    resources :profiles, only: [:show], param: :nickname, constraints: { nickname: %r{[^/]+} }, format: false
    scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^/]+} } do
      get "following", to: "profiles#following", as: "profile_following"
      get "followers", to: "profiles#followers", as: "profile_followers"
      get "badges", to: "profiles#badges", as: "profile_badges"
      get "activity", to: "user_activities#index", as: "profile_activity"
    end

    get "/open-data", to: "open_data#index", as: :open_data
    get "/open-data/download", to: "open_data#download", as: :open_data_download
    get "/open-data/download/:resource", to: "open_data#download", as: :open_data_download_resource
    get "/search", to: "searches#index", as: :search
    resources :last_activities, only: [:index]
    namespace :gamification do
      resources :badges, only: [:index]
    end

    root to: "homepage#show"
  end

  get "/last_activities", to: redirect(&locale_redirector("/last_activities", preserve_query_string: true))
  get "/search", to: redirect(&locale_redirector("/search", preserve_query_string: true))
  get "/pages", to: redirect(&locale_redirector("/pages"))
  get "/pages/*rest", to: redirect { |params, request| locale_redirector("/pages/#{params[:rest]}").call(params, request) }
  get "/gamification/*rest", to: redirect { |params, request| locale_redirector("/gamification/#{params[:rest]}").call(params, request) }
  get "/open-data/*rest", to: redirect { |params, request| locale_redirector("/open-data/#{params[:rest]}").call(params, request) }
  get "/open-data", to: redirect(&locale_redirector("/open-data"))
  get "/profiles/*rest", to: redirect { |params, request| locale_redirector("/profiles/#{params[:rest]}", preserve_query_string: true).call(params, request) }
  get "/notifications", to: redirect(&locale_redirector("/notifications"))

  get "/resource_autocomplete", to: "resource_autocomplete#index", as: :resource_autocomplete

  get "/link", to: "links#new", as: :link
  get "/qr-code", to: "qr#show", as: :qr

  get "/static_map", to: "static_map#show", as: :static_map
  put "/pages/terms-of-service/accept", to: "tos#accept_tos", as: :accept_tos

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  resource :follow, only: [:create, :destroy]
  resource :report, only: [:create]
  resource :report_user, only: [:create]
  resources :likes, only: [:create, :destroy]
  resources :amends, only: [:new], controller: :amendments do
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

  resources :newsletters, only: [:show] do
    get :unsubscribe, on: :collection
  end

  resources :upload_validations, only: [:create]

  resources :short_links, only: [:index, :show], path: "s"

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  scope :oauth do
    get "/me" => "doorkeeper/credentials#me"
  end
end
