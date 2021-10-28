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
              get :first_login
              get :renew_modal
              get :renew
            end
          end

          Decidim.authorization_engines.each do |manifest|
            mount manifest.engine, at: "/#{manifest.name}", as: "decidim_#{manifest.name}"
          end
        end

        namespace :admin do
          # Revocations - Two options: 1) Revoke all (without params) 2) Revoke before date (when date params exist)
          post "verifications_before_date", to: "verifications#destroy_before_date", as: "verifications/destroy_before_date"
          delete "verifications_all", to: "verifications#destroy_all", as: "verifications/destroy_all"
        end
      end

      # Initializer to include cells views paths
      initializer "decidim_verifications.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Verifications::Engine.root}/app/cells")
      end

      initializer "decidim_verifications.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
