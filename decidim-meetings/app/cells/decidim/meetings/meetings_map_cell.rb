# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsMapCell < MeetingMCell
      include Decidim::MapHelper
      include Decidim::Meetings::MapHelper

      def show
        return if Decidim.geocoder.blank?
        render
      end

      def geocoded_meetings
        @geocoded_meetings ||= meetings.select(&:geocoded?)
      end

      def meetings
        model
      end
    end
  end
end
