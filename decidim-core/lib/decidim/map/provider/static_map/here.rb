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
              z: options[:zoom] || 15,
              w: options[:width] || 120,
              h: options[:height] || 120,
              f: 1
            }

            api_key = configuration[:api_key]
            if api_key.is_a?(Array)
              # Legacy way of configuring the API credentials
              params[:app_id] = api_key[0]
              params[:app_code] = api_key[1]
            else
              # The new way of configuring the API key
              params[:apiKey] = api_key
            end

            params
          end
        end
      end
    end
  end
end
