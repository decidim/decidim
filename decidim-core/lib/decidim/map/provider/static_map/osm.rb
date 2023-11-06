# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module StaticMap
        # The static map utility class for the OpenStreetMap based map services
        class Osm < ::Decidim::Map::StaticMap
          # @See Decidim::Map::StaticMap#url_params
          def url_params(latitude:, longitude:, options: {})
            # This is the format used by osm-static-maps which is not an
            # official OSM product but it should be rather easy to setup. For
            # further information, see:
            # https://github.com/jperelli/osm-static-maps
            {
              geojson: {
                type: "Point",
                coordinates: [longitude, latitude]
              }.to_json,
              zoom: options[:zoom] || Decidim::Map::StaticMap::DEFAULT_ZOOM,
              width: options[:width] || Decidim::Map::StaticMap::DEFAULT_SIZE,
              height: options[:height] || Decidim::Map::StaticMap::DEFAULT_SIZE
            }
          end
        end
      end
    end
  end
end
