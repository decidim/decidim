# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedElementsCell < BaseCell
      include Decidim::ContentBlocks::HasRelatedComponents

      def published_components
        @published_components ||= if model.settings.try(:component_id).present?
                                    components.published.where(id: model.settings.component_id)
                                  else
                                    components.published
                                  end
      end

      def block_id
        "#{model.scope_name}-#{model.manifest_name}".parameterize.gsub("_", "-")
      end

      private

      def components
        @components ||= components_for(model)
      end
    end
  end
end
