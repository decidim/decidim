# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a taxonomy in the
    # system.
    class DestroyTaxonomyFilter < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          extra: {
            space_manifest: resource.try(:space_manifest),
            filter_items_count: resource.try(:filter_items_count)
          }
        }
      end
    end
  end
end
