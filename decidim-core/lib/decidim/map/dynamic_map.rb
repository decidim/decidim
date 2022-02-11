# frozen_string_literal: true

module Decidim
  module Map
    # A base class for dynamic mapping functionality, common to all dynamic map
    # services.
    class DynamicMap < Map::Frontend
      # Creates a builder class for the front-end that is used to build the map
      # HTML markup.
      #
      # @param (see Decidim::Map::DynamicMap::Builder#initialize)
      #
      # @return [Decidim::Map::DynamicMap::Builder] The builder object that can
      #   be used to build the map's markup.
      def create_builder(template, options = {})
        builder_class.new(template, builder_options.merge(options))
      end

      # Returns the builder class for the map. Allows fetching the class name
      # dynamically also in the utility classes that extend this class.
      #
      # @return [Class] The class for the builder object.
      def builder_class
        self.class.const_get(:Builder)
      end

      # Returns the options for the default builder object.
      #
      # @return [Hash] The default options for the map builder.
      def builder_options
        {
          marker_color: organization.colors.fetch("primary", "#ef604d"),
          tile_layer: tile_layer_configuration
        }
      end

      protected

      # Prepares the tile layer configuration hash to be passed for the
      # builder.
      #
      # @return The tile layer configuration hash.
      def tile_layer_configuration
        tile_layer = configuration.fetch(:tile_layer, {})
        tile_layer_options = tile_layer.except(:url).tap do |config|
          config.fetch(:api_key, nil) == true &&
            config[:api_key] = configuration.fetch(:api_key, nil)
        end

        {
          url: tile_layer.fetch(:url, nil),
          options: tile_layer_options
        }
      end

      # A builder for the dynamic maps to be used in the views. Provides all the
      # necessary functionality to display and initialize the maps.
      class Builder < Decidim::Map::Frontend::Builder
        # Displays the map element's markup for the view.
        #
        # @param html_options [Hash] Extra options to pass to the map element.
        # @return [String] The map element's markup.
        def map_element(html_options = {})
          map_html_options = {
            "data-decidim-map" => view_options.to_json,
            # The data-markers-data is kept for backwards compatibility
            "data-markers-data" => options.fetch(:markers, []).to_json
          }.merge(html_options)

          content = template.capture { yield }.html_safe if block_given?

          template.content_tag(:div, map_html_options) do
            (content || "")
          end
        end

        # @see Decidim::Map::View::Builder#stylesheet_snippets
        def stylesheet_snippets
          template.stylesheet_pack_tag("decidim_map")
        end

        # @see Decidim::Map::View::Builder#javascript_snippets
        def javascript_snippets
          [
            template.javascript_import_module_tag("src/decidim/map/provider/default"),
            template.javascript_import_module_tag("src/decidim/map")
          ].join
        end
      end
    end
  end
end
