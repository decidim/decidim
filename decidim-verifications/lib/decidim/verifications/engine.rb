# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Verifications
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Verifications

      routes do
        authenticate(:user) do
          resources :authorizations, only: [:new, :create, :index] do
            collection do
              get :onboarding_pending
              get :renew_modal
              get :renew
              delete :clear_onboarding_data
            end
          end

          Decidim.authorization_engines.each do |manifest|
            mount manifest.engine, at: "/#{manifest.name}", as: "decidim_#{manifest.name}"
          end
        end

        resources :authorizations, only: nil do
          post :renew_onboarding_data, on: :collection
        end

        namespace :admin do
          # Revocations - Two options: 1) Revoke all (without params) 2) Revoke before date (when date params exist)
          post "verifications_before_date", to: "verifications#destroy_before_date", as: "verifications/destroy_before_date"
          delete "verifications_all", to: "verifications#destroy_all", as: "verifications/destroy_all"
        end
      end

      initializer "decidim_verifications.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Verifications::Engine, at: "/", as: "decidim_verifications"
        end
      end

      initializer "decidim_verifications.mount_admin_routes" do
        Decidim::Core::Engine.routes do
          constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
            Decidim.authorization_admin_engines.each do |manifest|
              mount manifest.admin_engine, at: "/admin/#{manifest.name}", as: "decidim_admin_#{manifest.name}"
            end
          end
        end
      end

      # Initializer to include cells views paths
      initializer "decidim_verifications.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Verifications::Engine.root}/app/cells")
      end

      initializer "decidim_verifications.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_verifications.register_icons" do
        Decidim.icons.register(name: "fingerprint-2-line", icon: "fingerprint-2-line", category: "system", description: "", engine: :verifications)
        Decidim.icons.register(name: "message-3-line", icon: "message-3-line", category: "system", description: "", engine: :verifications)
      end
    end
  end
end
