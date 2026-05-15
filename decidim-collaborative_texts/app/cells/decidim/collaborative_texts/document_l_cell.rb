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
    end
  end
end
