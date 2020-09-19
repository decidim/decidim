# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Autocomplete
        # The geocoding autocomplete map utility class for the HERE map
        # services.
        class Here < ::Decidim::Map::Autocomplete
          class Builder < Decidim::Map::Autocomplete::Builder
            # @see Decidim::Map::FrontendUtility::Builder#javascript_snippets
            def javascript_snippets
              template.javascript_include_tag("decidim/geocoding/provider/here")
            end
          end
        end
      end
    end
  end
end
