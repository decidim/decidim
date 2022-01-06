# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent an Array.
    class Array < ActiveModel::Type::Value
      attr_reader :value_type, :default

      def initialize(value_type: ::Object, default: [])
        @value_type = value_type
        @default = default
      end

      def type # :nodoc:
        :array
      end

      # The nested validator should be only added for those attributes that
      # inherit from the AttributeObject::Model type. Otherwise this would be
      # also added e.g. for ActiveRecord objects which would cause unexpected
      # validation errors.
      #
      # The hash type inherits from the array type, so this covers both cases.
      def validate_nested?
        return false unless value_type.is_a?(Class)

        value_type <= Decidim::AttributeObject::Model
      end

      private

      def cast_value(value)
        value ||= default.dup

        if value.is_a?(::Hash)
          value = value.values
        elsif !value.is_a?(::Array)
          value =
            if value.respond_to?(:to_a)
              value.to_a
            else
              [value]
            end
        end

        value.map { |v| primitive_value(v, value_type) }
      end

      def primitive_value(value, type)
        return type.cast(value) if type.is_a?(ActiveModel::Type::Value)

        Decidim::AttributeObject.type(type).cast(value)
      end
    end
  end
end
