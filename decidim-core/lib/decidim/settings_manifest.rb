# frozen_string_literal: true

module Decidim
  # This class serves as a DSL that enables specifying an arbitrary settings
  # to a component, so the admin panel can show a standarized UI to configure them.
  #
  class SettingsManifest
    attr_reader :attributes

    # Initializes a SettingsManifest.
    def initialize
      @attributes = {}
    end

    # Public: Adds a new attribute field to the SettingsManifest.
    #
    # name - The name of the attribute to inject.
    # options - A set of options to configure the attribute.
    #           :type - The type of the attribute as found in Attribute::TYPES
    #           :default - The default value of this settings field.
    #
    # Returns nothing.
    def attribute(name, options = {})
      attribute = Attribute.new(options)
      attribute.validate!
      @attributes[name.to_sym] = attribute

      @schema = nil
    end

    # Public: Creates a model Class that sanitizes, coerces and filters data to
    # the right types given a hash of serialized information.
    #
    # Returns a Class.
    def schema
      return @schema if @schema

      manifest = self

      @schema = Class.new do
        include Decidim::AttributeObject::Model
        include ActiveModel::Validations
        include TranslatableAttributes

        cattr_accessor :manifest
        attr_reader :default_locale

        # Overwrites Decidim::AttributeObject::Model#initialize to allow
        # passing a default_locale needed to validate translatable attributes.
        # See TranslatablePresenceValidator#default_locale_for(record).
        def initialize(attributes = nil, default_locale = nil)
          @default_locale = default_locale
          super(attributes)
        end

        def self.model_name
          ActiveModel::Name.new(self, nil, "Settings")
        end

        def manifest
          self.class.manifest
        end

        manifest.attributes.each do |name, attribute|
          if attribute.translated?
            translatable_attribute name, attribute.type_class, default: attribute.default_value
            validates name, translatable_presence: true if attribute.required
          else
            attribute name, attribute.type_class, default: attribute.default_value
            validates name, presence: true if attribute.required
            validates name, inclusion: { in: attribute.build_choices } if attribute.type == :enum
          end
        end
      end

      @schema.manifest = self
      @schema
    end

    def required_attributes_for_authorization
      attributes.select { |_, attribute| attribute.required_for_authorization? }
    end

    # Semi-private: Attributes are an abstraction used by SettingsManifest
    # to encapsulate behavior related to each individual settings field. Shouldn't
    # be used from the outside.
    class Attribute
      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      TYPES = {
        boolean: { klass: Boolean, default: false },
        integer: { klass: Integer, default: 0 },
        string: { klass: String, default: nil },
        text: { klass: String, default: nil },
        array: { klass: Array, default: [] },
        enum: { klass: String, default: nil },
        select: { klass: String, default: nil },
        scope: { klass: Integer, default: nil },
        time: { klass: Decidim::Attributes::TimeWithZone, default: nil }
      }.freeze

      attribute :type, Symbol, default: :boolean
      # Expects a Proc. You can use this to return fake data to preview the attribute.
      attribute :preview
      attribute :default
      attribute :translated, Boolean, default: false
      attribute :editor, Boolean, default: false
      attribute :required, Boolean, default: false
      attribute :required_for_authorization, Boolean, default: false
      attribute :readonly
      attribute :choices
      attribute :include_blank, Boolean, default: false

      validates :type, inclusion: { in: TYPES.keys }

      def type_class
        TYPES[type][:klass]
      end

      def default_value
        default || TYPES[type][:default]
      end

      def build_choices
        choices.try(:call) || choices
      end

      def readonly?(context)
        readonly&.call(context)
      end
    end
  end
end
