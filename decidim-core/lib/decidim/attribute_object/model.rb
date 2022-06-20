# frozen_string_literal: true

# Make sure the custom attributes are defined
require "decidim/attributes"

module Decidim
  module AttributeObject
    # This provides a dummy model implementation for replacing the Virtus models
    # using ActiveModel. This class is a lightweight version of
    # `ActiveModel::Model` with the `ActiveModel::Attributes` module and its
    # overridden methods.
    #
    # The main purpose of this class is to provide a backwards compatible API
    # for defining classes that hold attributes, such as the form classes.
    #
    # Usage:
    #   Replace all instances of `Virtus.model` with `Decidim::AttributeObject::Model`.
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::AttributeAssignment
      include ActiveModel::Attributes
      include Decidim::AttributeObject::TypeMap

      included do
        extend ActiveModel::Naming
        extend ActiveModel::Translation

        # Default attributes for all models
        attribute :id
      end

      class_methods do
        def attribute(name, type = ActiveModel::Type::Value.new, **options)
          typedef = AttributeObject.types.resolve(type, **options)

          super(name, typedef[:type], **typedef[:options])

          # Create the boolean method alias with the question mark at the end
          # which is used in some places. This was a default behavior of
          # Virtus but not a feature in ActiveModel::Attributes.
          alias_method :"#{name}?", name if typedef[:type] == :boolean

          # Add the nested validation in case validations module is loaded and
          # the type reports it needs nested validations.
          return unless include?(ActiveModel::Validations)

          # The nested validator should be only added for those attributes that
          # inherit from the AttributeObject::Model type. Otherwise this would
          # be also added e.g. for ActiveRecord objects which would cause
          # unexpected validation errors.
          finaltype = attribute_types[name.to_s]
          return unless finaltype.respond_to?(:validate_nested?)
          return unless finaltype.validate_nested?

          validates_with(
            Decidim::AttributeObject::NestedValidator,
            _merge_attributes([name])
          )
        end
      end

      def initialize(attributes = {})
        # Parentheses needed not to pass the arguments.
        super()

        return unless attributes

        # Make sure the attributes is a hash
        base_attributes =
          if attributes.is_a?(Hash)
            attributes
          else
            attributes.to_h
          end

        # Only pass the existing attribute keys to assign_attributes
        # The regular expression matching makes sure we also include the "multi"
        # parameters, such as date fields passed from the view which are
        # formatted as date(1i), date(2i), date(3i). These are converted to
        # hashes below which are handled by the ActiveModel::Attributes types,
        # such as :date.
        correct_attributes = {}.tap do |attrs|
          base_attributes.each do |k, v|
            # Handle "multi" parameter attributes, such as date(1i), date(2i),
            # date(3i). This converts these three attributes to a single hash
            # attribute formatted as:
            #   { "date" => { 1 => ..., 2 => ..., 3 => ...  } }
            mp = k.to_s.match(/(.*)\(([0-9]+i)\)$/)
            if mp
              next unless attribute_names.include?(mp[1])

              attrs[mp[1]] ||= {}
              attrs[mp[1]][mp[2].to_i] = v
            else
              next unless attribute_names.include?(k.to_s)

              attrs[k] = v
            end
          end
        end

        assign_attributes(correct_attributes)
      end

      # This provides backwards compatibility for accessing the attributes
      # through symbols by calling `obj.attributes[:key]` or
      # `obj.attributes.slice(:key1, :key2)`. In the legacy Virtus models, this
      # returned a hash with symbol keys.
      #
      # Deprecated:
      # Attributes access through symbols is deprecated and may be removed in
      # future versions. Please refactor all your attributes calls to access the
      # attributes through string keys.
      def attributes
        super.with_indifferent_access
      end

      # Convenience method for accessing the attributes through
      # model[:attr_name] which is used in multiple places across the code.
      def [](attribute_name)
        public_send(attribute_name) if respond_to?(attribute_name)
      end

      # Convenience method for settings the attributes through
      # model[:attr_name] = "foo" which is used in some places across the code.
      def []=(attribute_name, value)
        public_send("#{attribute_name}=", value) if respond_to?("#{attribute_name}=")
      end

      # Convenience method used in initiatives
      def attributes_with_values
        to_h.compact
      end

      def to_h
        hash = attributes.to_h.symbolize_keys
        hash.delete(:id) if hash.has_key?(:id) && hash[:id].blank?

        hash
      end

      # The to_hash alias is needed for the as_json call which calls this method
      # if defined.
      alias to_hash to_h
    end
  end
end
