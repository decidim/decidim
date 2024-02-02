# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a scope.
    class DestroyScope < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          extra: {
            parent_name: resource.parent.try(:name),
            scope_type_name: resource.scope_type.try(:name)
          }
        }
      end
    end
  end
end
