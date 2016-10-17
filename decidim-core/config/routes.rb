# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/sessions",
               confirmations: "decidim/devise/confirmations",
               registrations: "decidim/devise/registrations",
               passwords: "decidim/devise/passwords"
             }

  resource :locale, only: [:create]
  resources :participatory_processes, only: [:index, :show]

  get "/pages/*id" => "pages#show", as: :page, format: false

  match "/404", to: "pages#show", id: "404", via: :all
  match "/500", to: "pages#show", id: "500", via: :all

  root to: "pages#show", id: "home"
end
