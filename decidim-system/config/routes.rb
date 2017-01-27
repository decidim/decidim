require 'sidekiq/web'

# frozen_string_literal: true
Decidim::System::Engine.routes.draw do
  devise_for :admins,
             class_name: "Decidim::System::Admin",
             module: :devise,
             router_name: :decidim_system,
             controllers: {
               sessions: "decidim/system/devise/sessions",
               passwords: "decidim/system/devise/passwords"
             }

  authenticate(:admin) do
    resources :organizations
    resources :admins
    mount Sidekiq::Web => "/sidekiq"

    root to: "dashboard#show"
  end
end
