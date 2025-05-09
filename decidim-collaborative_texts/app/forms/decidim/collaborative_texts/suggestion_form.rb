# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionForm < Decidim::Form
      include JsonbAttributes

      mimic :document

      jsonb_attribute :changeset, [
        [:original, Array[String]],
        [:replace, Array[String]],
        [:firstNode, Integer],
        [:lastNode, Integer]
      ]
      attribute :status, String, default: "pending"
      attribute :document_id, Integer

      validate :changes_exists

      alias author current_user

      def document
        @document ||= ::Decidim::CollaborativeTexts::Document.find(document_id)
      end

      def document_version
        @document_version ||= document.current_version
      end

      private

      def changes_exists
        errors.add(:base, I18n.t("errors.blank_changeset", scope: "decidim.collaborative_texts.suggestions")) if changeset.blank?
        if changeset["firstNode"].to_i.zero? || changeset["lastNode"].to_i.zero?
          errors.add(:base,
                     I18n.t("errors.invalid_nodes", scope: "decidim.collaborative_texts.suggestions"))
        end
      end
    end
  end
end
