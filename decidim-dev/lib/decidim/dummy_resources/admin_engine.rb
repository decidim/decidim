# frozen_string_literal: true

module Decidim
  module DummyResources
    class AdminEngine < Rails::Engine
      engine_name "dummy_admin"

      routes do
        resources :dummy_resources do
          resources :nested_dummy_resources
        end

        root to: proc { [200, {}, ["DUMMY ADMIN ENGINE"]] }
      end

      initializer "dummy_admin.imports" do
        class ::DummyCreator < Decidim::Admin::Import::Creator
          def self.resource_klass
            Decidim::DummyResources::DummyResource
          end

          def produce
            resource
          end

          private

          def resource
            @resource ||= Decidim::DummyResources::DummyResource.new(
              title: { en: "Dummy" },
              author: context[:current_user],
              component:
            )
          end

          def component
            context[:current_component]
          end
        end
      end
    end
  end
end
