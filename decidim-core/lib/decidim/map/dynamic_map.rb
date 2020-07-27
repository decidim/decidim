# frozen_string_literal: true

require "httparty"

module Decidim
  module Map
    # A base class for dynamic mapping functionality, common to all dynamic map
    # services.
    class DynamicMap < Map::Utility
      # Creates a builder class for the front-end that is used to build the map
      # HTML markup.
      #
      # @param (see Decidim::Map::DynamicMap::Builder#initialize)
      #
      # @return [Decidim::Map::DynamicMap::Builder] The builder object that can
      #   be used to build the map's markup.
      def create_builder(template, map_id, options = {})
        builder_class.new(template, map_id, builder_options.merge(options))
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
        tile_layer = configuration.fetch(:tile_layer, {})

        {
          tile_layer: {
            url: tile_layer.fetch(:url, nil),
            configuration: tile_layer.except(:url)
          }
        }
      end

      # A builder for the dynamic maps to be used in the views. Provides all the
      # necessary functionality to display and initialize the maps.
      class Builder
        # Initializes the map builder instance.
        #
        # @param template [ActionView::Template] The template within which the
        #   map is displayed.
        # @param map_id [String] The map element's ID reference.
        # @param options [Hash] Extra options for the builder object.
        def initialize(template, map_id, options)
          @template = template
          @map_id = map_id
          @options = options
        end

        # Displays the map element's markup for the view.
        #
        # @return [String] The map element's markup.
        def map_element(map_options = {})
          map_html_options = {
            id: map_id,
            "data-markers-data" => options.fetch(:markers, []).to_json
          }.merge(map_options)

          content = template.capture { yield }.html_safe if block_given?

          template.content_tag(:div, map_html_options) do
            (content || "")
          end + configuration_element(map_options).html_safe
        end

        # Returns the configuration tag that configures the map in the front-end
        # for the map service in question. This defaults to the Leaflet default
        # map tile layer configuration.
        #
        # @param config [Hash] A configuration hash for the map to be configured
        # @option config [String] :map_id The ID attribute of the HTML map
        #   element that can be referred to from the embedded JavaScript code.
        #
        # @return [String] A JavaScript tag for the map configurations.
        def configuration_element(map_options = {})
          url = options[:tile_layer][:url]
          return "" unless url

          element_id = map_options[:id] || map_id
          config = hash_to_js(options[:tile_layer][:configuration])

          template.javascript_tag do
            <<~JSCONF.strip.html_safe
              var $map = $("##{element_id}");
              $map.on("configure.decidim", function(_ev, map) {
                var tileLayerConfig = #{config.to_json};
                L.tileLayer(#{url.to_json}, tileLayerConfig).addTo(map);
              });
            JSCONF
          end
        end

        # Displays the necessary front-end stylesheet assets for the map
        # element.
        #
        # @return [String] The map element's stylesheet assets markup for the
        #   view.
        def stylesheet_snippets
          template.stylesheet_link_tag("decidim/map")
        end

        # Displays the necessary front-end JavaScript assets for the map
        # element.
        #
        # @return [String] The map element's JavaScript assets markup for the
        #   view.
        def javascript_snippets
          template.javascript_include_tag("decidim/map/default")
        end

        protected

        attr_reader :template, :map_id, :markers, :options

        # Converts a hash with Ruby-style key names (snake_case) to JS-style key
        # names (camelCase).
        #
        # @param [Hash] The original hash with Ruby-style hash keys in
        #   snake_case format.
        #
        # @return [Hash] The resulting hash with JS-style hash keys in camelCase
        #   format.
        def hash_to_js(hash)
          hash.map do |key, value|
            value = hash_to_js(value) if value.is_a?(Hash)
            value = value.call(self) if value.respond_to?(:call)

            [key.to_s.camelize(:lower), value]
          end.to_h
        end
      end
    end
  end
end
