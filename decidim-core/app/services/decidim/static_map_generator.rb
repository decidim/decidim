# frozen_string_literal: true
require "httparty"

module Decidim
  # This class generates a url to create a static map image for a geocoded resource
  class StaticMapGenerator
    BASE_HOST = "image.maps.cit.api.here.com"
    BASE_PATH = "/mia/1.6/mapview"

    def initialize(resource, options = {})
      @resource = resource
      @options = options

      @options[:zoom] ||= 15
      @options[:width] ||= 120
      @options[:height] ||= 120
    end

    def data
      return if Decidim.geocoder.nil?

      Rails.cache.fetch(@resource.cache_key) do
        request = HTTParty.get(uri)
        request.body
      end
    end

    private

    def uri
      params = {
        c: "#{@resource.latitude}, #{@resource.longitude}",
        z: @options[:zoom],
        w: @options[:width],
        h: @options[:height],
        f: "1",
        app_id: Decidim.geocoder&.fetch(:here_app_id),
        app_code: Decidim.geocoder&.fetch(:here_app_code)
      }

      uri = URI.parse("https://#{BASE_HOST}#{BASE_PATH}").tap do |uri|
        uri.query = URI.encode_www_form params
      end

      uri
    end
  end
end
