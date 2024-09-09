# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new taxonomy filter in the
    # system.
    class CreateTaxonomyFilter < Decidim::Commands::CreateResource
      fetch_form_attributes :root_taxonomy_id, :filter_items, :space_manifest

      protected

      def resource_class = Decidim::TaxonomyFilter

      def extra_params
        {
          extra: {
            space_manifest: form.try(:space_manifest),
            filter_items_count: form.try(:all_taxonomy_items).try(:count)
          }
        }
      end
    end
  end
end
