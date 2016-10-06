# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/sessions",
               registrations: "decidim/devise/registrations",
               passwords: "decidim/devise/passwords"
             }
  root to: "home#show"
end
