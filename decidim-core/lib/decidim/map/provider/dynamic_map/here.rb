# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module DynamicMap
        # The dynamic map utility class for the HERE maps service
        class Here < ::Decidim::Map::DynamicMap
          protected

          # @see Decidim::Map::DynamicMap#tile_layer_configuration
          def tile_layer_configuration
            base_config = configuration.fetch(:tile_layer, {})

            api_key = configuration[:api_key]

            base_config.merge(api_key:, language: language_code)
          end

          # A builder for the HERE maps which needs to be configured differently
          # than "normal" OSM based tile service providers.
          class Builder < Decidim::Map::DynamicMap::Builder
            # @see Decidim::Map::DynamicMap::Builder#append_assets
            def append_assets
              template.append_stylesheet_pack_tag("decidim_map")
              template.append_javascript_pack_tag("decidim_map_provider_here")
            end
          end

          private

          def language_code
            I18n.locale.to_s
          end
        end
      end
    end
  end
end
