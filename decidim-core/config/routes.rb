# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  devise_for :users, class_name: "Decidim::User", module: :'decidim/devise', router_name: :decidim
  root to: "home#show"
end
