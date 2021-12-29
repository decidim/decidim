# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Autocomplete
        # The geocoding autocomplete utility class for Photon based geocoding
        # autocompletion services which use the OpenStreetMap's (OSM) data.
        class Osm < ::Decidim::Map::Autocomplete
          class Builder < Decidim::Map::Autocomplete::Builder
            # @see Decidim::Map::FrontendUtility::Builder#javascript_snippets
            def javascript_snippets
              template.javascript_pack_tag("decidim_geocoding_provider_photon", defer: false)
            end
          end
        end
      end
    end
  end
end
