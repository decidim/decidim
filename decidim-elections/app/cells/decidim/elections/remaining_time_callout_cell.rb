# frozen_string_literal: true

module Decidim
  module Elections
    class RemainingTimeCalloutCell < Decidim::ViewModel
      helper_method :needs_to_show_remaining_time?, :remaining_time

      private

      def needs_to_show_remaining_time?
        model.end_time > Time.now.utc && model.end_time < 12.hours.from_now.utc
      end

      def remaining_time
        minutes_to_end = ((model.end_time - Time.now.utc) / 60).floor
        t("remaining_time", count: remaining_hours(minutes_to_end), minutes: remaining_minutes(minutes_to_end), scope: "decidim.elections.election_m.footer")
      end

      def remaining_hours(minutes_to_end)
        minutes_to_end / 60
      end

      def remaining_minutes(minutes_to_end)
        minutes_to_end % 60
      end
    end
  end
end
