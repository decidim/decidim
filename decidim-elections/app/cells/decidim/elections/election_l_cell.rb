# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Elections
    # This cell renders the Search (:s) election card
    # for a given instance of an Election
    class ElectionLCell < Decidim::CardLCell
      private

      def has_description?
        true
      end

      def title
        present(model).title(html_escape: true)
      end

      def description
        attribute = model.try(:short_description) || model.try(:body) || model.description
        text = translated_attribute(attribute)

        decidim_sanitize(html_truncate(text, length: 240), strip_tags: true)
      end

      def metadata_cell
        "decidim/elections/election_card_metadata"
      end
    end
  end
end
