# frozen_string_literal: true

module Decidim
  module Core
    class ComponentType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface
      description "A base component with no particular specificities."

      def self.authorized?(object, context)
        context[:component] = object
        context[:current_component] = object

        super && allowed_to?(:read, :component, object, context)
      end
    end
  end
end
