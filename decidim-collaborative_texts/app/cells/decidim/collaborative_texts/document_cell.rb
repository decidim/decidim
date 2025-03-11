# frozen_string_literal: true

require "cell/partial"

module Decidim
  module CollaborativeTexts
    # This cell renders the document card for an instance of a Document
    # the default size is the List Card (:l)
    class DocumentCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/collaborative_texts/document_l"
      end
    end
  end
end
