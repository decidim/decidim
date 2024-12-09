# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new taxonomy filter in the
    # system.
    class CreateTaxonomyFilter < Decidim::Commands::CreateResource
      fetch_form_attributes :root_taxonomy_id, :filter_items, :internal_name, :name, :participatory_space_manifests

      protected

      def resource_class = Decidim::TaxonomyFilter

      def extra_params
        {
          extra: {
            taxonomy_name: form.root_taxonomy.name,
            filter_items_count: form.filter_items.count
          }
        }
      end
    end
  end
end
