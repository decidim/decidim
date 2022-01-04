# frozen_string_literal: true

module Decidim
  module AttributeObject
    class NestedAttributes
      attr_reader :attributes

      delegate :each, :map, :keys, :values, :[], to: :attributes

      def initialize
        @attributes = {}
      end

      def initialize_copy(copy)
        # Make sure the copy has its own deep copy of the attributes hash so
        # that different inherited model instances are not modifying their
        # parents' nested attributes.
        copy.instance_variable_set(
          :@attributes,
          Marshal.load(Marshal.dump(@attributes))
        )
      end

      def add(name, type, options)
        @attributes[name] = { type: type, options: options }
      end

      def default_value(name)
        attributes[name][:options][:default]
      end

      def convert_value(name, value)
        type = attributes[name][:type]
        options = attributes[name][:options]

        if type == Hash
          convert_hash_value(value, options[:key_type], options[:value_type])
        elsif type == Array
          convert_array_value(value, options[:value_type])
        else
          value(value, type)
        end
      end

      def value(raw, type)
        return unless raw
        return raw if raw.is_a?(type) || (raw.is_a?(Class) && raw <= type)
        return type.new(raw.to_h) if type.include?(Decidim::AttributeObject::Model) || type <= ActiveRecord::Base || type == Object

        value_primitive(raw, type)
      end

      private

      def value_primitive(raw, type)
        return value_cast(raw, :to_s) if type == String
        return value_cast(raw, :to_sym) if type == Symbol
        return value_integer(raw) if type == Integer
        return value_float(raw) if type == Float

        type.new(raw)
      end

      def value_cast(raw, cast_method)
        return raw.public_send(cast_method) if raw.respond_to?(cast_method)

        raw
      end

      def value_integer(raw)
        return raw.to_i if raw.respond_to?(:to_i)
        return raw.id if raw.respond_to?(:id)

        Integer(raw)
      end

      def value_float(raw)
        return raw.to_f if raw.respond_to?(:to_f)

        Float(raw)
      end

      def convert_hash_value(value, key_type, value_type)
        value ||= {}
        value = value.to_h if !value.is_a?(Hash) && value.respond_to?(:to_h)

        # This preserves backwards compatibility for non-hash values e.g. with
        # the admin hero content block which expects the images container object
        # as the default value when building the admin form.
        return value unless value.is_a?(Hash)

        value.map do |k, v|
          [value(k, key_type), value(v, value_type)]
        end.to_h
      end

      def convert_array_value(value, value_type)
        if value.is_a?(Hash)
          value = value.values
        elsif !value.is_a?(Array)
          value =
            if value.respond_to?(:to_a)
              value.to_a
            else
              [value]
            end
        end

        value.map { |v| value(v, value_type) }
      end
    end
  end
end
