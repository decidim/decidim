# frozen_string_literal: true
require_dependency "decidim/components/route_constraint"

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

  scope "/participatory_processes/:participatory_process_id/components/:current_component_id" do
    Decidim.components.each do |component|
      constraints Decidim::Components::RouteConstraint.new(component) do
        mount component.engine, at: "/", as: :component
      end
    end
  end

  authenticate(:user) do
    resources :authorizations, only: [:new, :create, :destroy, :index]
    resource :account, only: [:show], controller: "account"
  end

  get "/pages/*id" => "pages#show", as: :page, format: false

  match "/404", to: "pages#show", id: "404", via: :all
  match "/500", to: "pages#show", id: "500", via: :all

  root to: "pages#show", id: "home"
end
