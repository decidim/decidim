# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class CollaborativeDraftMCell < Decidim::CardMCell
      include CollaborativeDraftCellsHelper

      def badge
        render
      end

      private

      def has_state?
        true
      end

      def title
        decidim_html_escape(present(model).title)
      end

      def description
        decidim_sanitize(present(model).body.truncate(100, separator: /\s/))
      end

      def has_badge?
        true
      end

      def badge_classes
        return super unless options[:full_badge]

        state_classes.concat(["label", "collaborative-draft-status"]).join(" ")
      end

      def statuses
        [:creation_date, :follow, :comments_count]
      end
    end
  end
end
