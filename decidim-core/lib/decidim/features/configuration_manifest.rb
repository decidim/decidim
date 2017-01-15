# frozen_string_literal: true
module Decidim
  # This class serves as a DSL that enables specifying an arbitrary configuration
  # to a feature, so the admin panel can show a standarized UI to configure them.
  #
  class FeatureConfigurationManifest
    attr_reader :attributes

    # Initializes a FeatureConfigurationManifest.
    def initialize
      @attributes = {}
    end

    # Public: Adds a new attribute field to the FeatureConfigurationManifest.
    #
    # name - The name of the attribute to inject.
    # options - A set of options to configure the attribute.
    #           :type - The type of the attribute as found in Attribute::TYPES
    #           :default - The default value of this configuration field.
    #
    # Returns nothing.
    def attribute(name, options = {})
      attribute = Attribute.new(options)
      attribute.validate!
      @attributes[name.to_sym] = attribute
    end

    # Public: Creates a model Class that sanitizes, coerces and filters data to
    # the right types given a hash of serialized information.
    #
    # Returns a Class.
    def schema
      configuration_schema = self

      @klass = Class.new do
        include Virtus.model
        include ActiveModel::Validations

        cattr_accessor :schema

        def self.model_name
          ActiveModel::Name.new(self, nil, "FeatureConfiguration")
        end

        def schema
          self.class.schema
        end

        configuration_schema.attributes.each do |name, attribute|
          attribute name, attribute.type_class, default: attribute.default_value
          validates name, presence: true
        end
      end

      @klass.schema = self
      @klass
    end

    # Semi-private: Attributes are an abstraction used by FeatureConfigurationManifest
    # to encapsulate behavior related to each individual configuration field. Shouldn't
    # be used from the outside.
    class Attribute
      include Virtus.model
      include ActiveModel::Validations

      TYPES = {
        boolean: { klass: Boolean, default: false },
        string: { klass: String, default: nil },
        text: { klass: String, default: nil }
      }.freeze

      attribute :type, Symbol, default: :boolean
      attribute :default

      validates :type, inclusion: { in: TYPES.keys }

      def type_class
        TYPES[type][:klass]
      end

      def default_value
        default || TYPES[type][:default]
      end
    end
  end
end
