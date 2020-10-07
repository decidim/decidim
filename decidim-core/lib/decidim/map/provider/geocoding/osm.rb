# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Geocoding
        # The geocoding utility class for OpenStreetMap's (OSM) Nominatim based
        # geocoding services
        class Osm < ::Decidim::Map::Geocoding
          # @see Decidim::Map::Geocoding#handle
          def handle
            @handle ||= :nominatim
          end

          protected

          # @see Decidim::Map::Utility#configure!
          def configure!(config)
            @configuration = config.merge(
              http_headers: {
                "User-Agent" => "Decidim/#{Decidim.version} (#{Decidim.application_name})",
                "Referer" => organization.host
              }
            )
          end
        end
      end
    end
  end
end
