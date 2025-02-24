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
  devise_for :api_users,
             class_name: "Decidim::Api::ApiUser",
             module: "decidim/Api",
             path: "/",
             router_name: :decidim_api,
             controllers: { sessions: "decidim/api/sessions" },
             only: :sessions

  authenticate(:admin) do
    resources :organizations, except: [:show, :destroy] do
      member do
        post :resend_invitation
      end
    end
    resources :admins, except: [:show]
    resources :oauth_applications
    resources :api_users, except: [:show]

    root to: "dashboard#show"
  end
end
