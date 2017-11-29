# frozen_string_literal: true

Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:edit, :update], controller: "organization" do
      resource :appearance, only: [:edit, :update], controller: "organization_appearance"
    end

    Decidim.participatory_space_manifests.each do |manifest|
      mount manifest.admin_engine, at: "/", as: "decidim_admin_#{manifest.name}"
    end

    resources :static_pages
    resources :scope_types, except: [:show]
    resources :scopes, except: [:show] do
      resources :scopes, except: [:show]
    end

    resources :authorization_workflows, only: :index

    Decidim.authorization_admin_engines.each do |manifest|
      mount manifest.admin_engine, at: "/#{manifest.name}", as: "decidim_admin_#{manifest.name}"
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
