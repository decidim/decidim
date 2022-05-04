# frozen_string_literal: true

module Decidim
  module Map
    # A module to contain map functionality specific to the OpenStreetMap (OSM)
    # based map providers.
    module Provider
      module Autocomplete
        autoload :Osm, "decidim/map/provider/autocomplete/osm"
      end

      module Geocoding
        autoload :Osm, "decidim/map/provider/geocoding/osm"
      end

      module DynamicMap
        autoload :Osm, "decidim/map/provider/dynamic_map/osm"
      end

      module StaticMap
        autoload :Osm, "decidim/map/provider/static_map/osm"
      end
    end
  end
end
