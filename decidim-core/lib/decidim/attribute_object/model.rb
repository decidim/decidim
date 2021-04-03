# frozen_string_literal: true

module Decidim
  module AttributeObject
    # This provides a proof of concept implementation for replacing the Virtus
    # models using ActiveModel. This class is a lightweight version of
    # ActiveModel::Model with the `ActiveModel::Attributes` module and its
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
          case type
          when Class
            attribute_class(name, type, **options)
          when Hash
            key_type = type.keys.first || String
            val_type = type.values.first || String

            attribute_nested(name, Hash, **options.merge(key_type: key_type, value_type: val_type))
          when Array
            attribute_nested(name, Array, **options.merge(value_type: type.first))
          else
            super
          end
        end

        def attribute_class(name, type, **options)
          if type.include?(Decidim::AttributeObject::Model) || type <= ActiveRecord::Base
            attribute_nested(name, type, **options)
          elsif type == Hash
            attribute(name, Hash[String => String], **options)
          elsif type == Array
            attribute(name, Array[String], **options)
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
          @attributes_nested ||= Decidim::AttributeObject::NestedAttributes.new
        end
      end

      def initialize(attributes = {})
        # Parentheses needed not to pass the arguments.
        super()

        if attributes
          # Only pass the existing attribute keys to assign_attributes
          correct_attributes = attributes.select { |k, _v| attribute_names.include?(k.to_s) }

          assign_attributes(correct_attributes)
        end
      end

      def attribute_names
        @attribute_names ||= self.class.attribute_types.keys.map(&:to_s) + self.class.attributes_nested.keys.map(&:to_s)
      end

      def to_h
        attributes.transform_keys(&:to_sym).merge(
          self.class.attributes_nested.keys.map { |attr| [attr, send(attr)] }.to_h
        )
      end
    end
  end
end
