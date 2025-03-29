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
      end
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
    resources :logs, only: [:index]
    resources :area_types, except: [:show]
    resources :areas, except: [:show]

    resources :authorization_workflows, only: :index

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
        post :bulk_new, controller: :block_user
        post :bulk_create, controller: :block_user
        delete :bulk_destroy, controller: :block_user
        patch :bulk_unreport, controller: :moderated_users
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
        get :confirm_recipients
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
      patch :bulk_action, on: :collection
      resources :reports, controller: "global_moderations/reports", only: [:index, :show]
    end

    resources :conflicts, only: [:index, :edit, :update], controller: "conflicts"

    resources :taxonomies, except: [:show] do
      patch :reorder, on: :collection
      resources :items, only: [:new, :create, :edit, :update], controller: "taxonomy_items"
      resources :filters, except: [:show], controller: "taxonomy_filters"
    end
    resources :taxonomy_filters_selector, param: :taxonomy_filter_id, except: [:edit, :update]

    root to: "dashboard#show"
  end
end
