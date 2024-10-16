# frozen_string_literal: true

Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resource :organization, only: [:edit, :update], controller: "organization" do
      resource :appearance, only: [:edit, :update], controller: "organization_appearance"
      resource :homepage, only: [:edit, :update], controller: "organization_homepage" do
        resources :content_blocks, only: [:edit, :update, :destroy, :create], controller: "organization_homepage_content_blocks"
      end
      resource :external_domain_allowlist, only: [:edit, :update], controller: "organization_external_domain_allowlist"

      member do
        get :users
        get :user_entities
      end
    end

    Decidim.participatory_space_manifests.each do |manifest|
      mount manifest.context(:admin).engine, at: "/", as: "decidim_admin_#{manifest.name}"
    end

    resources :static_pages do
      put :update_content_blocks, on: :member
      resources :content_blocks, only: [:edit, :update, :destroy, :create], controller: "static_page_content_blocks"
    end
    resources :static_page_topics
    resources :scope_types, except: [:show]
    resources :scopes, except: [:show] do
      resources :scopes, except: [:show]
    end
    resources :metrics, only: [:index]
    resources :logs, only: [:index]
    resources :area_types, except: [:show]
    resources :areas, except: [:show]

    resources :authorization_workflows, only: :index

    Decidim.authorization_admin_engines.each do |manifest|
      mount manifest.admin_engine, at: "/#{manifest.name}", as: "decidim_admin_#{manifest.name}"
    end

    mount Decidim::Templates::AdminEngine, at: "/templates", as: "decidim_admin_templates" if Decidim.module_installed?(:templates)

    resources :users, except: [:edit, :update], controller: "users" do
      member do
        post :resend_invitation, to: "users#resend_invitation"
      end
    end

    resources :officializations, only: [:new, :create, :index, :destroy], param: :user_id do
      member do
        get :show_email
      end
    end

    resources :moderated_users, only: [:index] do
      member do
        put :ignore
      end
      collection do
        scope "/:user_id" do
          resource :user_block, only: [:new, :create, :destroy], controller: :block_user
        end
      end
    end

    resources :impersonatable_users, only: [:index] do
      resources :promotions, controller: "managed_users/promotions", only: [:new, :create]
      resources :impersonation_logs, controller: "managed_users/impersonation_logs", only: [:index]
      resources :impersonations, controller: "impersonations", only: [:new, :create] do
        collection do
          post :close_session
        end
      end
    end

    resources :newsletter_templates, only: [:index, :show] do
      resources :newsletters, only: [:new, :create]

      member do
        get :preview
      end
    end

    resources :newsletters, except: [:new, :create] do
      member do
        post :recipients_count
        post :send_to_user
        get :preview
        get :select_recipients_to_deliver
        post :deliver
      end
    end

    resources :user_groups, only: [:index] do
      member do
        put :verify
        put :reject
      end
      collection do
        resource :user_groups_csv_verification, only: [:new, :create], path: "csv_verification"
      end
    end

    resource :help_sections, only: [:show, :update]

    namespace :admin_terms do
      get :show
      put :accept
    end

    resources :moderations, controller: "global_moderations" do
      member do
        put :unreport
        put :hide
        put :unhide
      end
      resources :reports, controller: "global_moderations/reports", only: [:index, :show]
    end

    resources :conflicts, only: [:index, :edit, :update], controller: "conflicts"

    root to: "dashboard#show"
  end
end
