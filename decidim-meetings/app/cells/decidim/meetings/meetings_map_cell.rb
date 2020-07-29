# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsMapCell < MeetingMCell
      include Decidim::MapHelper
      include Decidim::Meetings::MapHelper

      # The `content_for` method is needed by the map helper for injecting the
      # map JS/CSS into the document <head>.
      delegates :template, :content_for

      def show
        return unless Decidim::Map.available?(:geocoding, :dynamic)

        render
      end

      def geocoded_meetings
        @geocoded_meetings ||= meetings.select(&:geocoded?)
      end

      def meetings
        model
      end

      private

      def template
        @template ||= context[:view]
      end
    end
  end
end
