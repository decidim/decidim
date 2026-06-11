# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new taxonomy filter in the
    # system.
    class CreateTaxonomyFilter < Decidim::Commands::CreateResource
      fetch_form_attributes :root_taxonomy_id, :internal_name, :name, :participatory_space_manifests

      protected

      def resource_class = Decidim::TaxonomyFilter

      def run_after_hooks
        create_filter_items!
      end

      def extra_params
        {
          extra: {
            taxonomy_name: form.root_taxonomy.name,
            filter_items_count: selected_taxonomy_item_ids.size
          }
        }
      end

      private

      def create_filter_items!
        selected_taxonomy_item_ids.each { |taxonomy_item_id| resource.filter_items.create!(taxonomy_item_id:) }
      end

      def selected_taxonomy_item_ids
        form.taxonomy_items.map(&:to_i).uniq
      end
    end
  end
end
