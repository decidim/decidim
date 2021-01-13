# frozen_string_literal: true

module Decidim
  module Core
    module GraphQLApiTransition
      def self.included(base)
        ActiveSupport::Deprecation.warn(%Q(
        GraphQL is in migration mode. Class #{base.name} has been injected with Decidim::Core::GraphQLApiTransition module.
        ))
      end

      def object
        self
      end
    end
  end
end
