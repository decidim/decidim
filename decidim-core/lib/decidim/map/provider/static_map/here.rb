# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module StaticMap
        # The static map utility class for the HERE maps service
        class Here < ::Decidim::Map::StaticMap
          def url(latitude:, longitude:, options: {})
            map_url = configuration.fetch(:url, nil)
            return super unless map_url

            return super unless map_url.include?("mia/v3")

            w = options[:width] || Decidim::Map::StaticMap::DEFAULT_SIZE
            h = options[:height] || Decidim::Map::StaticMap::DEFAULT_SIZE

            params = {
              apiKey: configuration[:api_key],
              overlay: "point:#{latitude},#{longitude};icon=cp;size=large|#{latitude},#{longitude};style=circle;width=50m;color=%231B9D2C60"
            }

            URI.parse("#{map_url}:radius=90/#{w}x#{h}/png8").tap do |uri|
              uri.query = URI.encode_www_form(params)
            end.to_s
          end

          # @See Decidim::Map::StaticMap#url_params
          def url_params(latitude:, longitude:, options: {})
            ActiveSupport::Deprecation.warn(
              <<~DEPRECATION.strip
                Please use a V3 version HERE maps.
                For further information, see:
                https://www.here.com/docs/bundle/map-image-migration-guide-v3/page/README.html
                Also make sure your Decidim.maps configurations are using the
                up to date format.
                You need to change:
                  static_url = "https://image.maps.ls.hereapi.com/mia/1.6/mapview" if static_provider == "here" && static_url.blank?
                to:
                  static_url = "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" if static_provider == "here"
                in your config/initializers/decidim.rb file.
              DEPRECATION
            )

            params = {
              c: "#{latitude}, #{longitude}",
              z: options[:zoom] || Decidim::Map::StaticMap::DEFAULT_ZOOM,
              w: options[:width] || Decidim::Map::StaticMap::DEFAULT_SIZE,
              h: options[:height] || Decidim::Map::StaticMap::DEFAULT_SIZE,
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
