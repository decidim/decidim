# frozen_string_literal: true

Decidim::Design::Engine.routes.draw do
  namespace :components do
    get "forms", to: "forms#index"
    get "cards", to: "cards#index"
  end

  namespace :foundations do
    get "accessibility", to: "accessibility#index"
    get "color", to: "color#index"
    get "iconography", to: "iconography#index"
    get "layout", to: "layout#index"
    get "typography", to: "typography#index"
  end

  get "home", to: "home#index"

  root to: "home#index"
end
