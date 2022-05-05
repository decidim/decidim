# frozen_string_literal: true

# Decidim configuration.
module Decidim
  # A module containing the map functionality for Decidim.
  module Map
    autoload :Autocomplete, "decidim/map/autocomplete"
    autoload :DynamicMap, "decidim/map/dynamic_map"
    autoload :Geocoding, "decidim/map/geocoding"
    autoload :Provider, "decidim/map/provider"
    autoload :StaticMap, "decidim/map/static_map"
    autoload :Utility, "decidim/map/utility"
    autoload :Frontend, "decidim/map/frontend"

    # Public: Returns a boolean indicating whether the mapping functionality has
    # been configured.
    #
    # @return [Boolean] A boolean indicating whether the mapping functionality
    #   has been configured.
    def self.configured?
      configuration.present?
    end

    # Public: Returns a boolean indicating if the category of mapping services
    # is available for this instance that the provided key represents.
    #
    # @param *categories [Symbol] The utility category key to check the
    #   availability for.
    # @return [Boolean] A boolean indicating if the category of mapping services
    #   is available.
    def self.available?(*categories)
      categories.all? { |category| utility_class(category).present? }
    end

    # Public: Returns the full maps configuration hash.
    #
    # @return [Hash] The full map functionality configuration hash.
    def self.configuration
      Decidim.maps
    end

    # Public: Creates a new instance of the correct mapping utility class for
    # the category specified by the key argument.
    #
    # @param category [Symbol] The utility category key for the utility to be
    #   created.
    # @param options [Hash] The options for the utility constructor method.
    # @return [Decidim::Map::Utility] A new instance of the mapping utility.
    def self.utility(category, options)
      return unless (klass = utility_class(category))

      config = utility_configuration(category)
      options[:config] = config.except(:provider)
      klass.new(**options)
    end

    # Public: Returns the utility class module namespace for each category of
    # map utilities. The configured utility class (through Decidim.maps) is
    # should be under these namespaces.
    #
    # @return [Hash<Symbol, Module>] The modules within which the utility
    #   classes should be defined in.
    def self.utility_modules
      @utility_modules ||= {}
    end

    # Public: Registers a new category of map modules.
    #
    # @param category [Symbol] The key for the category.
    # @param mod [Module] The module to be assigned for the category.
    # @return [Module] The module which was assigned for the category.
    def self.register_category(category, mod)
      @utility_modules ||= {}
      @utility_modules[category] = mod

      # Dynamically define the category method.
      module_eval %{
        def self.#{category}(options)    # def self.dynamic(options)
          utility(:#{category}, options) #  utility(:dynamic, options)
        end                              # end
      }, __FILE__, __LINE__ - 4

      mod
    end

    # Public: Unregisters the given category of map modules. Mostly used for
    # testing but there can be also actual use cases for this.
    #
    # @param category [Symbol] The key for the category.
    # @return [Module, nil] The module which was previously assigned for the
    #   category or nil if no module was previously assigned for it.
    def self.unregister_category(category)
      return unless @utility_modules

      mod = @utility_modules.delete(category)
      @utility_configuration.delete(category) if @utility_configuration
      singleton_class.instance_eval do
        undef_method(category) if method_defined?(category)
      end
      mod
    end

    # Public: Sets and returns the utility specific configuration hash which
    # contains the prepared configuration objects for each category of
    # utilities.
    #
    # For example, given the following configuration:
    #   Decidim.configure do |config|
    #     config.maps = {
    #       provider: :osm,
    #       api_key: "apikey",
    #       global_conf: "value",
    #       dynamic: {
    #         tile_layer: {
    #           url: "https://tiles.example.org/{z}/{x}/{y}.png?{foo}",
    #           foo: "bar"
    #         }
    #       },
    #       static: {
    #         url: "https://staticmap.example.org/"
    #       },
    #       geocoding: {
    #         provider: :alternative,
    #         api_key: "gc_apikey",
    #         host: "https://nominatim.example.org/"
    #       }
    #     }
    #   end
    #
    # This would result in the following kind of configuration hash returned
    # by this method:
    #   {
    #     dynamic: {
    #       provider: :osm,
    #       api_key: "apikey",
    #       global_conf: "value",
    #       tile_layer: {
    #         url: "https://tiles.example.org/{z}/{x}/{y}.png?{foo}",
    #         foo: "bar"
    #       }
    #     }
    #     static: {
    #       provider: :osm,
    #       api_key: "apikey",
    #       global_conf: "value",
    #       url: "https://staticmap.example.org/"
    #     }
    #     geocoding: {
    #       provider: :alternative,
    #       api_key: "gc_apikey",
    #       global_conf: "value",
    #       host: "https://nominatim.example.org/"
    #     }
    #   }
    #
    # @param category [Symbol, nil] The key of the utility category for which to
    #   fetch the configuration for. When nil, returns the whole configuration
    #   hash.
    # @return [Hash] The configuration hash.
    def self.utility_configuration(category = nil)
      @utility_configuration ||= {}.tap do |config|
        break {} unless configuration

        global_config = configuration.except(*utility_modules.keys)
        utility_modules.keys.each do |key|
          utility_config = configuration.fetch(key, {})
          next if utility_config == false

          unless utility_config.is_a?(Hash)
            config[key] = global_config
            next
          end

          config[key] = global_config.merge(utility_config)
        end
      end
      return @utility_configuration[category] if category

      @utility_configuration
    end

    # Public: Resets the utility configuration to its initial state so that it
    # is reloaded when utility_configuration is called the next time. It should
    # not be necessary to call this ever but it is useful for the tests as the
    # configurations can change.
    #
    # @return [nil]
    def self.reset_utility_configuration!
      @utility_configuration = nil
    end

    # Public: Returns the full utility class name in the correct module
    # namespace for the given utility category. For example, if the provider
    # :osm is configured for the :dynamic utilities, the utility class returned
    # by this method is `Decidim::Map::Provider::DynamicMap::Osm`.
    #
    # @param category [Symbol] The category of utilities. E.g. `:dynamic`.
    # @return [Class] The configured mapping service provider key.
    def self.utility_class(category)
      return unless (ns = utility_modules[category])

      config = utility_configuration(category)
      return if config.blank?
      return unless (key = config[:provider])

      # Define the last part of the class name from the category provider's key,
      # e.g. by turning `:osm` to "Osm" or `:some_service` to "SomeService".
      subclass_name = key.to_s.camelize
      return unless ns.const_defined?(subclass_name)

      ns.const_get(subclass_name)
    end
  end
end
