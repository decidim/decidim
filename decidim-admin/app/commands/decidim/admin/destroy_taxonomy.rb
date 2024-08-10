# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a taxonomy.
    class DestroyTaxonomy < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          extra: {
            parent_name: resource.parent.try(:name)
          }
        }
      end
    end
  end
end
