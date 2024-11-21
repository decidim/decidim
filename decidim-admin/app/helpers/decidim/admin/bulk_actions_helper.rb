# frozen_string_literal: true

module Decidim
  module Admin
    module BulkActionsHelper
      # Public: Generates a select field with the components.
      #
      # siblings - A collection of components.
      #
      # Returns a String.
      def bulk_components_select(siblings)
        components = siblings.map do |component|
          [translated_attribute(component.name, component.organization), component.id]
        end

        prompt = t("decidim.proposals.admin.proposals.index.select_component")
        select(:target_component_id, nil, options_for_select(components, selected: []), prompt:)
      end
    end
  end
end
