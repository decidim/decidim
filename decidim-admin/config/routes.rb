# frozen_string_literal: true

Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:edit, :update], controller: "organization"
    resources :participatory_process_groups
    resources :participatory_processes do
      resource :publish, controller: "participatory_process_publications", only: [:create, :destroy]
      resources :copies, controller: "participatory_process_copies", only: [:new, :create]

      resources :steps, controller: "participatory_process_steps" do
        resource :activate, controller: "participatory_process_step_activations", only: [:create, :destroy]
        collection do
          post :ordering, to: "participatory_process_step_ordering#create"
        end
      end
      resources :user_roles, controller: "participatory_process_user_roles" do
        member do
          post :resend_invitation, to: "participatory_process_user_roles#resend_invitation"
        end
      end
      resources :attachments, controller: "participatory_process_attachments"
    end

    scope "/participatory_processes/:participatory_process_id" do
      resources :categories

      resources :features do
        resource :permissions, controller: "feature_permissions"
        member do
          put :publish
          put :unpublish
        end
        resources :exports, only: :create
      end

      resources :moderations do
        member do
          put :unreport
          put :hide
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
    end

    resources :static_pages
    resources :scope_types, except: [:show]
    resources :scopes, except: [:show] do
      resources :scopes, except: [:show]
    end

    resources :users, except: [:edit, :update], controller: "users" do
      member do
        post :resend_invitation, to: "users#resend_invitation"
      end
    end

    resources :managed_users, controller: "managed_users", except: [:edit, :update] do
      resources :promotions, controller: "managed_users/promotions", only: [:new, :create]
      resources :impersonations, controller: "managed_users/impersonations", only: [:index, :new, :create] do
        collection do
          post :close_session
        end
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
        put :reject
      end
    end

    root to: "dashboard#show"
  end
end
