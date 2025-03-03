# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionForm < Decidim::Form
      include JsonbAttributes

      mimic :document

      jsonb_attribute :changeset, [
        [:replace, Array[String]],
        [:firstNode, Integer],
        [:lastNode, Integer]
      ]
      attribute :status, String, default: "pending"
      attribute :document_id, Integer

      def author
        context[:current_user]
      end

      def document
        @document ||= ::Decidim::CollaborativeTexts::Document.find(document_id)
      end

      def document_version
        @document_version ||= document.current_version
      end
    end
  end
end
