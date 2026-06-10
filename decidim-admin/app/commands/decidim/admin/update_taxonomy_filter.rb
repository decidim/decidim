# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to update an existing taxonomy filter
    # in the system.
    class UpdateTaxonomyFilter < Decidim::Commands::UpdateResource
      fetch_form_attributes :internal_name, :name, :participatory_space_manifests

      protected

      def resource_class = Decidim::TaxonomyFilter

      def run_after_hooks
        sync_filter_items!
      end

      def extra_params
        {
          extra: {
            taxonomy_name: resource.root_taxonomy.name,
            filter_items_count: selected_taxonomy_item_ids.size
          }
        }
      end

      private

      def sync_filter_items!
        removed_ids = current_taxonomy_item_ids - selected_taxonomy_item_ids
        added_ids = selected_taxonomy_item_ids - current_taxonomy_item_ids

        resource.filter_items.where(taxonomy_item_id: removed_ids).destroy_all if removed_ids.any?
        added_ids.each { |taxonomy_item_id| resource.filter_items.create!(taxonomy_item_id:) }
      end

      def current_taxonomy_item_ids
        resource.filter_items.pluck(:taxonomy_item_id)
      end

      def selected_taxonomy_item_ids
        form.taxonomy_items.map(&:to_i).uniq
      end
    end
  end
end
