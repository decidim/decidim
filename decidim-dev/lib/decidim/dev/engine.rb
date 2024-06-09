# frozen_string_literal: true

require "decidim/dev/needs_development_tools"

module Decidim
  module Dev
    # Decidim's development Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Dev
      engine_name "decidim_dev"

      routes do
        root to: proc { [200, {}, ["DUMMY ENGINE"]] }

        resources :dummy_resources do
          resources :nested_dummy_resources
          get :foo, on: :member
        end
      end

      initializer "decidim_dev.tools" do
        # Disable if the boost performance mode is enabled
        next if Rails.application.config.try(:boost_performance)

        ActiveSupport.on_load(:action_controller) { include Decidim::Dev::NeedsDevelopmentTools } if Rails.env.development? || ENV.fetch("DECIDIM_DEV_ENGINE", nil)
      end

      initializer "decidim_dev.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_dev.middleware.test_map_server" do |app|
        next unless Rails.env.test?

        require "decidim/dev/test/map_server"

        # Add the test map server as the first middleware in the stack
        app.config.middleware.insert_before 0, Decidim::Dev::Test::MapServer
      end

      initializer "decidim_dev.moderation_content" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::Dev::HideAllCreatedByAuthorJob.perform_later(**data)
          end
        end
      end
    end
  end
end
