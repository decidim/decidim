# frozen_string_literal: true

module Decidim
  module Map
    # A base class for geocoding functionality, common to all geocoding
    # services.
    class Geocoding < Map::Utility
      # @see Decidim::Map::Utility#initialize
      def initialize(organization:, config:, locale: I18n.locale.to_s)
        super
        prepare!
      end

      # The "lookup" handle to be passed to the geocoder gem. For the full list,
      # see https://github.com/alexreisner/geocoder/blob/master/README_API_GUIDE.md.
      #
      # @return [Symbol] The handle of the geocoder gem's lookup
      def handle
        @handle ||= self.class.name.to_s.split("::")[-1].underscore.to_sym
      end

      # A common search method to lookup information about an address or
      # coordinates from the geocoder.
      #
      # @param query [String, Array(<Float, String>, <Float, String>)] The
      #   search query to be passed to the geocoder
      # @param options [Hash] Extra options to be provided for the geocoder
      #   search
      #
      # @return [Array(Float, Float), String, nil] The corresponding result for
      #   the search query, either a string or an array containing the result
      #   coordinates or nil when no corresponding result was found.
      def search(query, options = {})
        Geocoder.search(query, geocoder_options(options))
      end

      # Does a geocoding request with the given address and returns the
      # corresponding geocoordinates as an array where the first element
      # corresponds the latitude and the second element corresponds to the
      # longitude.
      #
      # @param address [String] The address to search the geocoordinates for
      # @param options [Hash] Extra options to be provided for the geocoder
      #   search
      #
      # @return [Array(Float, Float), nil] The corresponding coordinates found
      #  by the geocoder where the first element corresponds to the latitude
      #  coordinate and the second element corresponds to the longitude
      #  coordinate or nil when no result was found
      def coordinates(address, options = {})
        Geocoder.coordinates(address, geocoder_options(options))
      end

      # Does a reverse geocoding request with the given geocoordinates
      # (latitude/longitude) coordinates and returns a clear text address for
      # the closest result.
      #
      # @param coordinates [Array(<Float, String>, <Float, String>)] An array of
      #   the coordinates where the first element is the latitude and the second
      #   element is the longitude
      # @param options [Hash] Extra options to be provided for the geocoder
      #   search
      #
      # @return [String, nil] The corresponding address found by the geocoder
      #   or nil when no result was found
      def address(coordinates, options = {})
        results = search(coordinates, options)
        return if results.empty?

        results.sort! do |result1, result2|
          dist1 = Geocoder::Calculations.distance_between(
            result1.coordinates,
            coordinates
          )
          dist2 = Geocoder::Calculations.distance_between(
            result2.coordinates,
            coordinates
          )
          dist1 <=> dist2
        end

        results.first.address
      end

      protected

      # @see Decidim::Map::Utility#configure
      def configure!(config)
        @configuration = config.merge(
          http_headers: { "Referer" => organization.host }
        )
      end

      # Prepares the options to be passed to the Geocoder gem.
      #
      # @param options [Hash] The options hash to be passed to Geocoder.
      #
      # @return [Hash]
      def geocoder_options(options)
        { lookup: handle, language: locale }.merge(options)
      end

      private

      # Prepares the geocoder for the lookups with the configured geocoding
      # service. This is called when an instance of the geocoding utility is
      # created.
      #
      # @return [void]
      def prepare!
        Geocoder.configure(handle => configuration)
      end
    end
  end
end
