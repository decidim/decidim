# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsMapCell < MeetingMCell
      include Decidim::MapHelper
      include Decidim::Meetings::MapHelper

      delegate :snippets, to: :controller

      def show
        return unless Decidim::Map.available?(:geocoding, :dynamic)

        render
      end

      def geocoded_meetings
        @geocoded_meetings ||= meetings.select(&:geocoded_and_valid?)
      end

      def meetings
        model
      end
    end
  end
end
