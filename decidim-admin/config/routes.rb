# frozen_string_literal: true
require_dependency "decidim/components/route_constraint"

Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:show, :edit, :update], controller: "organization"
    resources :participatory_processes do
      resource :publish, controller: "participatory_process_publications", only: [:create, :destroy]

      resources :categories

      resources :steps, controller: "participatory_process_steps" do
        resource :activate, controller: "participatory_process_step_activations", only: [:create, :destroy]
        collection do
          post :ordering, to: "participatory_process_step_ordering#create"
        end
      end
      resources :user_roles, controller: "participatory_process_user_roles", only: [:destroy, :create, :index]
      resources :attachments, controller: "participatory_process_attachments"
      resources :features
      resources :components, only: [:new, :create, :destroy]
    end

    scope "/participatory_processes/:participatory_process_id/features/:feature_id/components/:current_component_id" do
      Decidim.component_manifests.each do |manifest|
        constraints Decidim::Components::RouteConstraint.new(manifest) do
          mount manifest.admin_engine, at: "/"
        end
      end

      get "/" => proc { raise "Component not found" }, as: :manage_component
    end

    resources :static_pages

    root to: "dashboard#show"
  end
end
