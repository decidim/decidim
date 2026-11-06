# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This cell renders the List (:l) post card
    # for a given instance of a Post
    class DocumentLCell < Decidim::CardLCell
      private

      def has_description?
        false
      end

      def metadata_cell
        "decidim/collaborative_texts/document_metadata"
      end
    end
  end
end
