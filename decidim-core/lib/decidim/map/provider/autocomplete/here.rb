# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Autocomplete
        # The geocoding autocomplete map utility class for the HERE map
        # services.
        class Here < ::Decidim::Map::Autocomplete
          class Builder < Decidim::Map::Autocomplete::Builder
            # @see Decidim::Map::FrontendUtility::Builder#append_assets
            def append_assets
              template.append_javascript_pack_tag("decidim_geocoding_provider_here")
            end
          end
        end
      end
    end
  end
end
