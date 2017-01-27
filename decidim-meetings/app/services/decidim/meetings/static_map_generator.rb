# frozen_string_literal: true
module Decidim
  module Meetings
    # This class generates a url to create a static map image for a geocoded meeting
    class StaticMapGenerator
      BASE_HOST = "mage.maps.cit.api.here.com"
      BASE_PATH = "/mia/1.6/mapview"

      def initialize(meeting, options = {})
        @meeting = meeting
        @options = options

        @options[:zoom] ||= 15
        @options[:width] ||= 120
        @options[:height] ||= 120
      end

      def uri
        params = {
          c: "#{@meeting.latitude}, #{@meeting.longitude}",
          z: @options[:zoom],
          w: @options[:width],
          h: @options[:height],
          f: "1",
          app_id: Decidim.geocoder&.fetch(:api_key)&.first,
          app_code: Decidim.geocoder&.fetch(:api_key)&.last
        }

        uri = URI.parse("https://#{BASE_HOST}#{BASE_PATH}").tap do |uri|
          uri.query = URI.encode_www_form params
        end

        uri
      end
    end
  end
end
