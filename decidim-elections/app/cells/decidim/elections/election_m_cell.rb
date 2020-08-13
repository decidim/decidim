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

      def spans_multiple_dates?
        start_date != end_date
      end

      def election_date
        return unless start_date && end_date
        return render(:multiple_dates) if spans_multiple_dates?

        render(:single_date)
      end

      def formatted_start_time
        model.start_time.strftime("%H:%M")
      end

      def formatted_end_time
        model.end_time.strftime("%H:%M")
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
