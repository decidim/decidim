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

  resources :participatory_process_groups, only: :show, path: "processes_groups"
  resources :participatory_processes, only: [:index, :show], path: "processes" do
    resources :participatory_process_steps, only: [:index], path: "steps"
  end

  scope "/processes/:participatory_process_id/f/:feature_id" do
    Decidim.feature_manifests.each do |manifest|
      next unless manifest.engine

      constraints Decidim::CurrentFeature.new(manifest) do
        mount manifest.engine, at: "/", as: "decidim_#{manifest.name}"
      end
    end

    get "/", to: redirect("/404"), as: :feature
  end

  authenticate(:user) do
    resources :authorizations, only: [:new, :create, :index] do
      collection do
        get :first_login
      end
    end
    resource :account, only: [:show, :update], controller: "account"
    resource :notifications_settings, only: [:show, :update], controller: "notifications_settings"
    resources :own_user_groups, only: [:index]
  end

  resources :pages, only: [:index, :show], format: false

  get "/static_map", to: "static_map#show", as: :static_map
  get "/cookies/accept", to: "cookie_policy#accept", as: :accept_cookies

  match "/404", to: "pages#show", id: "404", via: :all
  match "/500", to: "pages#show", id: "500", via: :all

  if Rails.env.development? && defined?(LetterOpenerWeb::Engine)
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root to: "pages#show", id: "home"
end
