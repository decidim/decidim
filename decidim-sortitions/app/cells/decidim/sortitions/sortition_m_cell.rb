# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Sortitions
    # This cell renders a sortition with its M-size card.
    class SortitionMCell < Decidim::CardMCell
      include Decidim::Sortitions::Engine.routes.url_helpers

      private

      def has_author?
        false
      end

      def has_state?
        true
      end

      # Even though we need to render the badge, we can't do it in the normal
      # way, because the paragraph comes from a user input and contains HTML.
      # This causes the badge and the paragraph to appear in different lines.
      # In order to fix it, check the `description` method.
      def has_badge?
        false
      end

      def badge_name
        return t("filters.cancelled", scope: "decidim.sortitions.sortitions") if model.cancelled?

        t("filters.active", scope: "decidim.sortitions.sortitions")
      end

      def state_classes
        return ["muted"] if model.cancelled?

        ["success"]
      end

      def proposals_count
        @proposals_count = model.proposals.count
      end

      # In order to render the badge inline with the paragraph text we need to
      # find the opening `<p>` tag and include the badge right after it. This
      # makes the layout look good.
      def description
        text = decidim_sanitize(translated_attribute(model.additional_info))
        text.gsub!(/^<p>/, "<p>#{render :badge}")
        html_truncate(text, length: 100)
      end
    end
  end
end
