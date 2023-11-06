# frozen_string_literal: true

module Decidim
  module Dev
    # Decidim's development Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Dev
      engine_name "decidim_dev"

      initializer "decidim_dev.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          namespace :design do
            namespace :components do
              get "forms", to: "forms#index"
              get "cards", to: "cards#index"
              get "spacing", to: "spacing#index"
            end

            # namespace :foundations do; end

            get "home", to: "home#index"

            root to: "home#index"
          end
        end
      end

      initializer "decidim_dev.tools" do
        # Disable if the boost performance mode is enabled
        next if Rails.application.config.try(:boost_performance)

        ActiveSupport.on_load(:action_controller) { include Decidim::Dev::NeedsDevelopmentTools }
      end

      initializer "decidim_dev.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
