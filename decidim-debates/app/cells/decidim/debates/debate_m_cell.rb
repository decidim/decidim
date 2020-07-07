# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders the Medium (:m) debate card
    # for an given instance of a Debate
    class DebateMCell < Decidim::CardMCell
      include DebateCellsHelper

      def date
        render
      end

      private

      def title
        present(model).title
      end

      def body
        decidim_sanitize(present(model).description)
      end

      def description
        strip_tags(body).truncate(200, separator: /\s/)
      end

      def resource_icon
        icon "debates", class: "icon--big"
      end

      def spans_multiple_dates?
        start_date != end_date
      end

      def debate_date
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
    end
  end
end
