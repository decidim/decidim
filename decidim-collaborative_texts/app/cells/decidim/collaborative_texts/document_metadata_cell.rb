# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This cell renders metadata for an instance of a Document for collaborative texts
    class DocumentMetadataCell < Decidim::CardMetadataCell
      def initialize(*)
        super

        @items.prepend(*document_items)
      end

      private

      def document_items
        [status_item, suggestions_count_item]
      end

      def status_item
        {
          text: t("decidim.collaborative_texts.document.card_status.#{status_key}"),
          icon: "time-line",
          data_attributes: { status: status_key }
        }
      end

      def status_key
        return "draft" if model.draft?
        return "accepting_suggestions" if model.suggestions_enabled?

        "not_accepting_suggestions"
      end

      def suggestions_count_item
        {
          text: t("decidim.collaborative_texts.document.suggestions_count", count: model.suggestions_count),
          icon: "award-line",
          data_attributes: { suggestions_count: "" }
        }
      end
    end
  end
end
