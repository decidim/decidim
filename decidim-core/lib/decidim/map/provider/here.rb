# frozen_string_literal: true

module Decidim
  module Map
    # A module to contain map functionality specific to the HERE map provider.
    module Provider
      module Autocomplete
        autoload :Here, "decidim/map/provider/autocomplete/here"
      end

      module Geocoding
        autoload :Here, "decidim/map/provider/geocoding/here"
      end

      module DynamicMap
        autoload :Here, "decidim/map/provider/dynamic_map/here"
      end

      module StaticMap
        autoload :Here, "decidim/map/provider/static_map/here"
      end
    end
  end
end
