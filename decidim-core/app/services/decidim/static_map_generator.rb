# frozen_string_literal: true

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
      return if @resource.blank? || map_utility.nil?

      Rails.cache.fetch(@resource.cache_key) do
        map_utility.image_data(
          latitude: @resource.latitude,
          longitude: @resource.longitude,
          options: @options
        )
      end
    end

    private

    def organization
      @organization ||= @resource.component.organization
    end

    def map_utility
      @map_utility ||= Decidim::Map.static(organization:)
    end
  end
end
