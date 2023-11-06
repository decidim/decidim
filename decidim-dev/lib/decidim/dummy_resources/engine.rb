# frozen_string_literal: true

module Decidim
  module DummyResources
    # Dummy engine to be able to test components.
    class DummyEngine < Rails::Engine
      engine_name "dummy"
      isolate_namespace Decidim::DummyResources

      routes do
        root to: proc { [200, {}, ["DUMMY ENGINE"]] }

        resources :dummy_resources do
          resources :nested_dummy_resources
          get :foo, on: :member
        end
      end

      initializer "dummy.moderation_content" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::DummyResources::HideAllCreatedByAuthorJob.perform_later(**data)
          end
        end
      end
    end
  end
end
