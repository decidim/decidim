# frozen_string_literal: true

Decidim::Design::Engine.routes.draw do
  namespace :components do
    get "cards", to: "cards#index"
  end

  resources :foundations, only: :show
  resources :components, only: :show

  get "home", to: "home#index"

  root to: "home#index"
end
