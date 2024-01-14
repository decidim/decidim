# frozen_string_literal: true

Decidim::Design::Engine.routes.draw do
  resources :foundations, only: :show
  resources :components, only: :show

  get "home", to: "home#index"

  root to: "home#index"
end
