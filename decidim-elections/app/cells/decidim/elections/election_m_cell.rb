# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the Medium (:m) election card
    # for a given instance of an Election
    class ElectionMCell < Decidim::CardMCell
      include ElectionCellsHelper

      def date
        render
      end

      private

      def title
        present(model).title
      end

      def description
        present(model).description(strip_tags: true)
      end

      def resource_icon
        icon "elections", class: "icon--big"
      end

      def start_date
        return unless model.start_time

        model.start_time.to_date
      end

      def end_date
        return unless model.end_time

        model.end_time.to_date
      end

      def statuses
        []
      end
    end
  end
end
