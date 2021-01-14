# frozen_string_literal: true

module Decidim
  module Core
    module GraphQLApiTransition
      def self.included(base)
        ActiveSupport::Deprecation.warn(%(
        GraphQL is in migration mode. Class #{base.name} has been injected with Decidim::Core::GraphQLApiTransition module.
        ))
      end

      def total_comments_count
        object.comments_count
      end

      # rubocop:disable Naming/PredicateName
      def has_comments
        object.comment_threads.size.positive?
      end
      # rubocop:enable Naming/PredicateName

      def object
        self
      end
    end
  end
end
