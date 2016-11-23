# frozen_string_literal: true
require_dependency "decidim/components/route_constraint"

# frozen_string_literal: true
Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:show, :edit, :update], controller: "organization"
    resources :participatory_processes do
      resource :publish, controller: "participatory_process_publications", only: [:create, :destroy]

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

    scope "/participatory_processes/:participatory_process_id/components/:current_component_id" do
      Decidim.components.each do |component|
        constraints Decidim::Components::RouteConstraint.new(component) do
          mount component.admin_engine, at: "/", as: :manage_component
        end
      end
    end

    resources :static_pages

    root to: "dashboard#show"
  end
end
