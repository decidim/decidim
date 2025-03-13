# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # Custom helpers, scoped to the collaborative texts engine.
    module ApplicationHelper
      include PaginateHelper
      include SanitizeHelper

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.collaborative_texts.name")
      end
    end
  end
end
