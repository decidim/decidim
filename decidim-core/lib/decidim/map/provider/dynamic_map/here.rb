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

            base_config.merge(api_key: api_key, language: language_code)
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

          # rubocop: disable Metrics/CyclomaticComplexity
          # rubocop: disable Lint/DuplicateBranch
          def language_code
            case I18n.locale.to_s
            when "ar" then "ara" # Arabic
            when "eu" then "baq" # Basque
            when "ca" then "cat" # Catalan
            when "zh-cn" then "chi" # Chinese (simplified)
            # when "" then "cht" # Chinese (traditional)
            when "cs" then "cze" # Czech
            when "da" then "dan" # Danish
            when "nl" then "dut" # Dutch
            when "en" then "eng" # English
            when "fi" then "fin" # Finnish
            when "fi-pl" then "fin"
            when "fi-plain" then "fin"
            when "fr" then "fre" # French
            when "fr-ca" then "fre"
            when "fr-lu" then "fre"
            when "de" then "ger" # German
            when "ga" then "gle" # Gaelic
            when "el" then "gre" # Greek
            # when "he" then "heb" # Hebrew
            # when "hi" then "hin" # Hindi
            when "id" then "ind" # Indonesian
            when "it" then "ita" # Italian
            when "no" then "nor" # Norwegian
            # when "fa" then "per" # Persian
            when "pl" then "pol" # Polish
            when "pt" then "por"; # Portuguese
            when "pt-br" then "por"
            when "ru" then "rus" # Russian
            when "si" then "sin" # Sinhalese
            when "es" then "spa" # Spanish
            when "es-mx" then "spa"
            when "es-py" then "spa"
            when "sv" then "swe" # Swedish
            # when "th" then "tha" # Thai
            when "tr" then "tur" # Turkish
            when "uk" then "ukr" # Ukrainian
            # when "ur" then "urd" # Urdu
            when "vi" then "vie" # Vietnamese
            # when "cy" then "wel" # Welsh
            else
              ""
            end
          end
          # rubocop: enable Lint/DuplicateBranch
          # rubocop: enable Metrics/CyclomaticComplexity
        end
      end
    end
  end
end
