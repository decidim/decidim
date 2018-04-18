# frozen_string_literal: true

module Decidim
  module Admin
    module BulkActionsHelper
      # Renders an actions dropdown, including an item
      # for each bulk action.
      #
      # Returns a rendered dropdown.
      def bulk_actions_dropdown
        render partial: "decidim/admin/bulk_actions/dropdown"
      end

      # Renders a form to change the category of selected items
      #
      # Returns a rendered form.
      def bulk_action_recategorize
        render partial: "decidim/admin/bulk_actions/recategorize"
      end

      def proposal_find(id)
        Decidim::Proposals::Proposal.find(id)
      end

      # Public: Generates a select field with the categories. Only leaf categories can be set as selected.
      #
      # categories - A collection of categories.
      #
      # Returns a String.
      def bulk_categories_select(collection)
        categories = bulk_categories_for_select collection
        disabled = bulk_disabled_categories_for collection
        prompt = t("decidim.proposals.admin.proposals.index.change_category")
        select(:category, :id, options_for_select(categories, selected: [], disabled: disabled), prompt: prompt)
      end

      def bulk_categories_for_select(scope)
        sorted_main_categories = scope.first_class.includes(:subcategories).sort_by do |category|
          translated_attribute(category.name, category.participatory_space.organization)
        end

        sorted_main_categories.flat_map do |category|
          parent = [[translated_attribute(category.name, category.participatory_space.organization), category.id]]

          sorted_subcategories = category.subcategories.sort_by do |subcategory|
            translated_attribute(subcategory.name, subcategory.participatory_space.organization)
          end

          sorted_subcategories.each do |subcategory|
            parent << ["- #{translated_attribute(subcategory.name, subcategory.participatory_space.organization)}", subcategory.id]
          end

          parent
        end
      end

      def bulk_disabled_categories_for(scope)
        scope.first_class.joins(:subcategories).pluck(:id)
      end
    end
  end
end
