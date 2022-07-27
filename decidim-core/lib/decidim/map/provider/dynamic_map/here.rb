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
            if api_key.is_a?(Array)
              # Support for legacy style configurations
              ActiveSupport::Deprecation.warn(
                <<~DEPRECATION.strip
                  Please use a single api_key configuration for HERE maps.

                  For further information, see:
                  https://developer.here.com/documentation/maps/3.1.16.1/dev_guide/topics/migration.html

                  Also make sure your Decidim.maps configurations are using the
                  up to date format.
                DEPRECATION
              )

              return base_config.merge(
                app_id: api_key[0],
                app_code: api_key[1]
              )
            end

            base_config.merge(api_key:, language: language_code)
          end

          # A builder for the HERE maps which needs to be configured differently
          # than "normal" OSM based tile service providers.
          class Builder < Decidim::Map::DynamicMap::Builder
            # @see Decidim::Map::DynamicMap::Builder#javascript_snippets
            def javascript_snippets
              template.javascript_pack_tag("decidim_map_provider_here", defer: false)
            end
          end

          private

          def language_code
            primary = I18n.locale.to_s
            secondary = primary.split("-")[0]
            available_language_codes[primary] || available_language_codes[secondary] || ""
          end

          def available_language_codes
            @available_language_codes ||= {
              "ar" => "ara", # Arabic
              "eu" => "baq", # Basque
              "ca" => "cat", # Catalan
              "zh" => "chi", # Chinese (simplified)
              # "" => "cht", # Chinese (traditional)
              "cs" => "cze", # Czech
              "da" => "dan", # Danish
              "nl" => "dut", # Dutch
              "en" => "eng", # English
              "fi" => "fin", # Finnish
              "fr" => "fre", # French
              "de" => "ger", # German
              "ga" => "gle", # Gaelic
              "el" => "gre", # Greek
              "he" => "heb", # Hebrew
              "hi" => "hin", # Hindi
              "id" => "ind", # Indonesian
              "it" => "ita", # Italian
              "no" => "nor", # Norwegian
              "fa" => "per", # Persian
              "pl" => "pol", # Polish
              "pt" => "por", # Portuguese
              "ru" => "rus", # Russian
              "si" => "sin", # Sinhalese
              "es" => "spa", # Spanish
              "sv" => "swe", # Swedish
              "th" => "tha", # Thai
              "tr" => "tur", # Turkish
              "uk" => "ukr", # Ukrainian
              "ur" => "urd", # Urdu
              "vi" => "vie", # Vietnamese
              "cy" => "wel" # Welsh
            }
          end
        end
      end
    end
  end
end
