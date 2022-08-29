# frozen_string_literal: true

module Decidim
  module Map
    # A base class for static mapping functionality, common to all static map
    # services.
    class StaticMap < Map::Utility
      # Creates a link for the static maps. This will point to an external map
      # service where the user can further explore the given location.
      #
      # @param params [Hash] The parameters for the static map URL
      # @option params [Float, String] :latitude The latitude of the map
      #   position to be linked to
      # @option params [Float, String] :longitude The longitude of the map
      #   position to be linked to
      # @option params [Hash] :options Extra options that can be provided to the
      #   map URL containing the following keys:
      #   * zoom: A number to represent the zoom value of the map (default 17)
      #
      # @return [String] The link where the static map images link to.
      def link(latitude:, longitude:, options: {})
        zoom = options.fetch(:zoom, 17)
        base_url = configuration.fetch(
          :link,
          "https://www.openstreetmap.org/"
        )

        params = { mlat: latitude, mlon: longitude }
        fragment = "map=#{zoom}/#{latitude}/#{longitude}"

        URI.parse(base_url).tap do |uri|
          uri.query = URI.encode_www_form(params)
          uri.fragment = fragment
        end.to_s
      end

      # Creates a URL that generates a static map image for the given map
      # location with the given options.
      #
      # @param params [Hash] The parameters for the static map URL
      # @option params [Float, String] :latitude The latitude of the map
      #   position
      # @option params [Float, String] :longitude The longitude of the map
      #   position
      # @option params [Hash] :options Extra options that can be provided to
      #   the underlying map service to generate the image with containing the
      #   following keys:
      #   * zoom: A number to represent the zoom value of the map image (default
      #     15)
      #   * width: A number to represent the pixel width of the map image
      #     (default 120)
      #   * height: A number to represent the pixel height of the map image
      #     (default 120)
      #
      # @return [String] The URL to request for the static map image.
      def url(latitude:, longitude:, options: {})
        map_url = configuration.fetch(:url, nil)
        return unless map_url

        # If a lambda or proc is passed as the :static_map_url configuration.
        if map_url.respond_to?(:call)
          return map_url.call(
            latitude:,
            longitude:,
            options:
          ).to_s
        end

        # Fetch the "extra" parameters from the configured map URL
        configured_uri = URI.parse(map_url)
        configured_params = Rack::Utils.parse_nested_query(
          configured_uri.query
        ).symbolize_keys

        # Generate a base URL without the URL parameters
        configured_uri.query = nil
        configured_uri.fragment = nil
        base_url = configured_uri.to_s

        # Generate the actual parameters by combining the configured parameters
        # with the provider specific parameters, giving priority to the
        # dynamically set parameters.
        params = configured_params.merge(
          url_params(
            latitude:,
            longitude:,
            options:
          )
        )

        # Generate the actual URL to call with all the prepared parameters.
        URI.parse(base_url).tap do |uri|
          uri.query = URI.encode_www_form(params)
        end.to_s
      end

      # Prepares the URL params for the static map URL.
      #
      # @param (see #url)
      #
      # @return [Hash] The parameters to pass to the static map image URL.
      def url_params(latitude:, longitude:, options: {})
        {
          latitude:,
          longitude:,
          zoom: options.fetch(:zoom, 15),
          width: options.fetch(:width, 120),
          height: options.fetch(:height, 120)
        }
      end

      # Creates a static map image data for the given map location with the
      # given options.
      #
      # @param (see #url)
      #
      # @return [String] The raw data for the image.
      def image_data(latitude:, longitude:, options: {})
        request_url = url(
          latitude:,
          longitude:,
          options:
        )
        return "" unless request_url

        response = Faraday.get(request_url) do |req|
          req.headers["Referer"] = organization.host
        end
        response.body
      end
    end
  end
end
