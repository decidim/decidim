module Decidim
  class FeatureConfiguration
    attr_reader :attributes

    def initialize
      @attributes = {}
    end

    def attribute(name, options = {})
      attribute = Attribute.new(options)
      attribute.validate!
      @attributes[name.to_sym] = attribute
    end

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

    class Attribute
      include Virtus.model
      include ActiveModel::Validations

      TYPES = {
        boolean: { klass: Boolean, default: false },
        string: { klass: String, default: nil },
        text: { klass: String, default: nil }
      }.freeze

      attribute :type, Symbol, default: :boolean
      validates :type, inclusion: { in: TYPES.keys }

      def type_class
        TYPES[type][:klass]
      end

      def default_value
        TYPES[type][:default]
      end
    end
  end
end
