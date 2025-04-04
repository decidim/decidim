# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # Custom helpers, scoped to the collaborative texts engine.
    module ApplicationHelper
      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.collaborative_texts.name")
      end

      def document_i18n
        {
          selectionActive: t("decidim.collaborative_texts.document.status.selection_active"),
          rolloutConfirm: t("decidim.collaborative_texts.document.rollout.confirm"),
          consolidateConfirm: t("decidim.collaborative_texts.document.consolidate.confirm")
        }
      end
    end
  end
end
