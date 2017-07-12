# frozen_string_literal: true

Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:edit, :update], controller: "organization"

    Decidim.featurable_manifests.each do |manifest|
      mount manifest.admin_engine, at: "/", as: "decidim_admin_#{manifest.name}"
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
        put :reject
      end
    end

    root to: "dashboard#show"
  end
end
