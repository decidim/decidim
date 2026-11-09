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
        [status_item, suggestions_count_item, contributors_count_item]
      end

      def status_item
        {
          text: t("decidim.collaborative_texts.document.card_status.#{status_key}"),
          icon: "time-line",
          data_attributes: { status: status_key }
        }
      end

      def status_key
        @status_key ||=
          if model.draft?
            "draft"
          elsif model.suggestions_enabled?
            "accepting_suggestions"
          else
            "not_accepting_suggestions"
          end
      end

      def suggestions_count_item
        {
          text: t("decidim.collaborative_texts.document.suggestions_count", count: model.suggestions_count),
          icon: "award-line",
          data_attributes: { suggestions_count: "" }
        }
      end

      def contributors_count_item
        {
          text: t("decidim.collaborative_texts.document.contributors_count", count: model.coauthorships_count),
          icon: "group-line",
          data_attributes: { contributors_count: "" }
        }
      end
    end
  end
end
