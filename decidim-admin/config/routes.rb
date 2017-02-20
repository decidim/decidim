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

      resources :features do
        resource :permissions, controller: "feature_permissions"
        member do
          put :publish
          put :unpublish
        end
      end
    end

    scope "/participatory_processes/:participatory_process_id/features/:feature_id/manage" do
      Decidim.feature_manifests.each do |manifest|
        next unless manifest.admin_engine

        constraints Decidim::CurrentFeature.new(manifest) do
          mount manifest.admin_engine, at: "/", as: "decidim_admin_#{manifest.name}"
        end
      end

      get "/", to: redirect("/404"), as: :manage_feature
    end

    resources :static_pages
    resources :scopes, except: [:show]
    resources :users, except: [:edit, :update], controller: "users" do
      member do
        post :resend_invitation, to: "users#resend_invitation"
      end
    end

    resources :newsletters do
      member do
        get :preview
        post :deliver
      end
    end

    resources :user_groups, only: [:index] do
      member do
        put :verify
      end
    end

    root to: "dashboard#show"
  end
end
