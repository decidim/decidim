# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # Custom helpers, scoped to the collaborative texts engine.
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper

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

      def filter_sections
        @filter_sections ||= [{
          method: :with_any_state,
          name: "[with_any_state]",
          collection: filter_document_state_values,
          label: t("decidim.collaborative_texts.documents.filters.state"),
          id: "state"
        }]
      end

      def filter_document_state_values
        %w(open in_review closed).map { |key| [key, t(key, scope: "decidim.collaborative_texts.documents.filters.state_values")] }
                                 .prepend(["all", t("all", scope: "decidim.collaborative_texts.documents.filters")])
      end
    end
  end
end
