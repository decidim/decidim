# frozen_string_literal: true

require "httparty"

module Decidim
  # This class generates a url to create a static map image for a geocoded resource
  class StaticMapGenerator
    def initialize(resource, options = {})
      @resource = resource
      @options = options

      @options[:zoom] ||= 15
      @options[:width] ||= 120
      @options[:height] ||= 120
    end

    def data
      return if Decidim.geocoder.nil? || @resource.blank?

      Rails.cache.fetch(@resource.cache_key) do
        request = HTTParty.get(uri, headers: { "Referer" => organization.host })
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
        app_id: Decidim.geocoder.fetch(:here_app_id),
        app_code: Decidim.geocoder.fetch(:here_app_code)
      }

      URI.parse(Decidim.geocoder.fetch(:static_map_url)).tap do |uri|
        uri.query = URI.encode_www_form params
      end
    end

    def organization
      @organization ||= @resource.feature.organization
    end
  end
end
