# frozen_string_literal: true

module Decidim
  module Map
    # A base class for front-end mapping functionality, common to all front-end
    # map services, such as dynamic_map.rb and autocomplete.rb. Provides builder
    # classes for the front-end.
    class Frontend < Map::Utility
      # Creates a builder class for the front-end that is used to build the HTML
      # markup related to this utility.
      #
      # @param (see Decidim::Map::BuilderUtility::Builder#initialize)
      #
      # @return [Decidim::Map::BuilderUtility::Builder] The builder object that
      #   can be used to build the map's markup.
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

      # Returns the default options for the builder object.
      #
      # @return [Hash] The default options for the map builder.
      def builder_options
        configuration
      end

      # A general builder for any functionality needed for the views. Provides
      # all the necessary functionality to display and initialize the front-end
      # elements related to the given map utility.
      class Builder
        # Initializes the map builder instance.
        #
        # @param template [ActionView::Template] The template within which the
        #   map is displayed.
        # @param options [Hash] Extra options for the builder object.
        def initialize(template, options)
          @template = template
          @options = options
        end

        # Displays the necessary front-end stylesheet assets for the map
        # element.
        #
        # @return [String, nil] The map element's stylesheet assets markup for
        #   the view or nil if there are no stylesheet assets.
        def stylesheet_snippets; end

        # Displays the necessary front-end JavaScript assets for the map
        # element.
        #
        # @return [String, nil ] The map element's JavaScript assets markup for
        #   the view or nil if there are no JavaScript assets.
        def javascript_snippets; end

        protected

        attr_reader :template, :options

        # Returns the options hash that will be passed to the map element as a
        # JSON encoded data attribute. These configurations can be used to pass
        # information to the front-end map functionality, e.g. about the tile
        # layer configurations and markers data.
        #
        # @return [Hash] The configurations passed to the map element's data
        #   attribute.
        def view_options
          hash_to_js(options)
        end

        # Converts a hash with Ruby-style key names (snake_case) to JS-style key
        # names (camelCase).
        #
        # @param [Hash] The original hash with Ruby-style hash keys in
        #   snake_case format.
        #
        # @return [Hash] The resulting hash with JS-style hash keys in camelCase
        #   format.
        def hash_to_js(hash)
          hash.to_h do |key, value|
            value = hash_to_js(value) if value.is_a?(Hash)
            value = value.call(self) if value.respond_to?(:call)

            [key.to_s.camelize(:lower), value]
          end
        end
      end
    end
  end
end
