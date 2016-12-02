# frozen_string_literal: true
Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:edit, :update], controller: "organization"
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
    end

    scope "/participatory_processes/:participatory_process_id/features/:feature_id/manage" do
      Decidim.feature_manifests.each do |manifest|
        next unless manifest.admin_engine

        constraints lambda { |request|
          feature = Decidim::CurrentFeature.new(request).call
          feature.manifest.name == manifest.name
        } do
          mount manifest.admin_engine, at: "/"
        end
      end

      get "/" => proc { raise "Feature not found" }, as: :manage_feature
    end

    resources :static_pages
    resources :scopes, except: [:show]

    root to: "dashboard#show"
  end
end
