# frozen_string_literal: true
require "httparty"

module Decidim
  module Meetings
    # This class generates a url to create a static map image for a geocoded meeting
    class StaticMapGenerator
      BASE_HOST = "image.maps.cit.api.here.com"
      BASE_PATH = "/mia/1.6/mapview"

      def initialize(meeting, options = {})
        @meeting = meeting
        @options = options

        @options[:zoom] ||= 15
        @options[:width] ||= 120
        @options[:height] ||= 120
      end

      def data
        return if Decidim.geocoder.nil?

        Rails.cache.fetch(@meeting.cache_key) do
          request = HTTParty.get(uri)
          request.body
        end
      end

      private

      def uri
        params = {
          c: "#{@meeting.latitude}, #{@meeting.longitude}",
          z: @options[:zoom],
          w: @options[:width],
          h: @options[:height],
          f: "1",
          app_id: Decidim.geocoder&.fetch(:here_app_id)&.first,
          app_code: Decidim.geocoder&.fetch(:here_app_code)&.last
        }

        uri = URI.parse("https://#{BASE_HOST}#{BASE_PATH}").tap do |uri|
          uri.query = URI.encode_www_form params
        end

        uri
      end
    end
  end
end
