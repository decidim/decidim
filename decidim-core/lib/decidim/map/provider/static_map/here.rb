# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module StaticMap
        # The static map utility class for the HERE maps service
        class Here < ::Decidim::Map::StaticMap
          # @See Decidim::Map::StaticMap#url_params
          def url_params(latitude:, longitude:, options: {})
            params = {
              c: "#{latitude}, #{longitude}",
              z: options[:zoom] || Decidim::Map::StaticMap::DEFAULT_ZOOM,
              w: options[:width] || Decidim::Map::StaticMap::DEFAULT_SIZE,
              h: options[:height] || Decidim::Map::StaticMap::DEFAULT_SIZE,
              f: 1
            }

            configuration[:api_key]

            params
          end
        end
      end
    end
  end
end
