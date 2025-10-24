# frozen_string_literal: true

module Decidim
  module Dev
    class DummyCreator < Decidim::Admin::Import::Creator
      def self.resource_klass
        Decidim::Dev::DummyResource
      end

      def produce
        resource
      end

      private

      def resource
        @resource ||= Decidim::Dev::DummyResource.new(
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
