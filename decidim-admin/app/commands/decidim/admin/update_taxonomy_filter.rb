# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new taxonomy filter in the
    # system.
    class UpdateTaxonomyFilter < Decidim::Commands::UpdateResource
      fetch_form_attributes :filter_items, :internal_name, :name, :participatory_space_manifests

      protected

      def resource_class = Decidim::TaxonomyFilter

      def run_before_hooks
        resource.filter_items.destroy_all
      end

      def extra_params
        {
          extra: {
            filter_items_count: form.try(:all_taxonomy_items).try(:count)
          }
        }
      end
    end
  end
end
