# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the Medium (:m) meeting card
    # for an given instance of a Meeting
    class MeetingMCell < Decidim::Meetings::MeetingCell
      include Decidim::TooltipHelper

      def show
        render
      end

      private

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def resource_icon
        icon "meetings", class: "icon--big"
      end

      def spans_multiple_dates?
        start_date != end_date
      end

      def meeting_date
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
        model.start_time.to_date
      end

      def end_date
        model.end_time.to_date
      end
    end
  end
end
