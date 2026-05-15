# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the List (:l) meeting card
    # for an instance of a Meeting
    class MeetingLCell < Decidim::CardLCell
      alias meeting model

      def extra_class
        "card__calendar-list__reset"
      end

      # Renders the date in the meeting card list
      def has_image?
        true
      end

      def image
        render
      end

      def url_extra_params
        return options[:url_extra_params] if options[:url_extra_params]
        return {} unless defined?(current_component)
        return {} if current_component == meeting.component

        { previous_space: "#{current_space.class}##{current_space.id}" }
      end

      private

      def current_space
        @current_space ||= current_component.participatory_space
      end

      def same_month?
        return true if meeting.end_time.blank?

        meeting.start_time.year == meeting.end_time.year && meeting.start_time.month == meeting.end_time.month
      end

      def same_day?
        return true if meeting.end_time.blank?

        meeting.start_time.to_date == meeting.end_time.to_date
      end

      def same_year?
        return true if meeting.end_time.blank?

        meeting.start_time.year == meeting.end_time.year
      end

      def metadata_cell
        "decidim/meetings/meeting_card_metadata"
      end
    end
  end
end
