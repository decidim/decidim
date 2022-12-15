# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Debates
    # This cell renders the List (:l) meeting card
    # for an instance of a Meeting
    class DebateLCell < Decidim::CardLCell
      include Decidim::SanitizeHelper
      delegate :component_settings, to: :controller

      alias debate model

      def item_list_class
        "debate-list card__list"
      end

      def has_header?
        true
      end

      def title
        decidim_html_escape(translated_attribute(model.title))
      end

      def description
        attribute = model.try(:short_description) || model.try(:body) || model.description
        text = translated_attribute(attribute)

        decidim_sanitize(html_truncate(text, length: 240))
      end

      private

      def metadata_cell
        "decidim/debates/debate_card_metadata"
      end
    end
  end
end
