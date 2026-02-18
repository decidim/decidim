# frozen_string_literal: true

Decidim::System::Engine.routes.draw do
  devise_for :admins,
             class_name: "Decidim::System::Admin",
             module: :devise,
             router_name: :decidim_system,
             controllers: {
               sessions: "decidim/system/devise/sessions",
               passwords: "decidim/system/devise/passwords"
             }

  authenticate(:admin) do
    resources :organizations, except: [:show, :destroy] do
      member do
        post :resend_invitation
      end
    end
    resources :admins, except: [:show]
    resources :oauth_applications
    resources :api_users, except: [:show] if Decidim.module_installed?(:api)

    root to: "dashboard#show"
  end
end
