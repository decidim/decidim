# frozen_string_literal: true

Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:edit, :update], controller: "organization" do
      resource :appearance, only: [:edit, :update], controller: "organization_appearance"
      resource :homepage, only: [:edit, :update], controller: "organization_homepage"

      member do
        get :users
      end
    end

    Decidim.participatory_space_manifests.each do |manifest|
      mount manifest.context(:admin).engine, at: "/", as: "decidim_admin_#{manifest.name}"
    end

    resources :static_pages
    resources :scope_types, except: [:show]
    resources :scopes, except: [:show] do
      resources :scopes, except: [:show]
    end
    resources :logs, only: [:index]
    resources :area_types, except: [:show]
    resources :areas, except: [:show]

    resources :authorization_workflows, only: :index

    Decidim.authorization_admin_engines.each do |manifest|
      mount manifest.admin_engine, at: "/#{manifest.name}", as: "decidim_admin_#{manifest.name}"
    end

    resources :users, except: [:edit, :update], controller: "users" do
      member do
        post :resend_invitation, to: "users#resend_invitation"
      end
    end

    resources :officializations, only: [:new, :create, :index, :destroy], param: :user_id

    resources :impersonatable_users, only: [:index] do
      resources :promotions, controller: "managed_users/promotions", only: [:new, :create]
      resources :impersonation_logs, controller: "managed_users/impersonation_logs", only: [:index]
      resources :impersonations, controller: "impersonations", only: [:new, :create] do
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

    resources :oauth_applications

    root to: "dashboard#show"
  end
end
