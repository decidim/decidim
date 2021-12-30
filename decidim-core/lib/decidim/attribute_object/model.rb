# frozen_string_literal: true

# Make sure the custom attributes are defined
require "decidim/attributes"

module Decidim
  module AttributeObject
    # This provides a dummy model implementation for replacing the Virtus models
    # using ActiveModel. This class is a lightweight version of
    # ActiveModel::Model with the `ActiveModel::Attributes` module and its
    # overridden methods + adds the support for nested attributes.
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
          case type
          when Class
            attribute_class(name, type, **options)
          when Hash
            key_type = type.keys.first || String
            val_type = type.values.first || String
            options[:default] ||= {}

            attribute_nested(name, Hash, **options.merge(key_type: key_type, value_type: val_type))
          when Array
            options[:default] ||= []

            attribute_nested(name, Array, **options.merge(value_type: type.first))
          else
            super

            # Create the boolean method alias with the question mark at the end
            # which is used in some places. This was a default behavior of
            # Virtus but not a feature in ActiveModel::Attributes.
            alias_method :"#{name}?", name if type == Boolean
          end
        end

        def attribute_class(name, type, **options)
          primitive_types = [Object, Proc, Rails::Engine, ActiveSupport::Duration]
          if primitive_types.include?(type) || type.include?(Decidim::AttributeObject::Model) || type <= ActiveRecord::Base
            attribute_nested(name, type, **options)
          elsif type == Hash
            attribute(name, Hash[String => Object], **options)
          elsif type == Array
            attribute(name, Array[Object], **options)
          else
            # Off the bat, this handles the basic types from:
            # https://github.com/rails/rails/tree/main/activemodel/lib/active_model/type
            #
            # Custom types would need special handling.
            attribute(name, type.to_s.underscore.to_sym, **options)
          end
        end

        def attribute_nested(name, type, **options)
          attributes_nested.add(name, type, options)

          # The parent module provides the backwards compatible `super` access
          # to the attributes when the attribute methods are overridden in the
          # extending model class.
          unless @attributes_parent
            @attributes_parent = Module.new
            include @attributes_parent
          end

          @attributes_parent.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}
              @#{name} || self.class.attributes_nested.default_value(:#{name})
            end

            def #{name}=(value)
              @#{name} = self.class.attributes_nested.convert_value(:#{name}, value)
            end
          RUBY

          if include?(ActiveModel::Validations)
            validates_with(
              Decidim::AttributeObject::NestedValidator,
              _merge_attributes([name])
            )
          end
        end

        def attributes_nested
          @attributes_nested ||=
            if (defined?(Decidim::Form) && superclass == ::Decidim::Form) || !superclass.respond_to?(:attributes_nested)
              Decidim::AttributeObject::NestedAttributes.new
            else
              superclass.attributes_nested.dup
            end
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

      def attribute_names
        @attribute_names ||= self.class.attribute_types.keys.map(&:to_s) + self.class.attributes_nested.keys.map(&:to_s)
      end

      def to_h
        hash = attributes.transform_keys(&:to_sym).merge(
          self.class.attributes_nested.keys.index_with { |attr| send(attr) }
        )
        hash.delete(:id) if hash.has_key?(:id) && hash[:id].blank?

        hash
      end

      # The to_hash alias is needed for the as_json call which calls this method
      # if defined.
      alias to_hash to_h
    end
  end
end
