# frozen_string_literal: true

module Decidim
  module Admin
    # A command to update a taxonomy.
    class UpdateTaxonomy < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :parent_id

      protected

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
