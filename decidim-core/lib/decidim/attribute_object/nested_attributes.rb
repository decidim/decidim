# frozen_string_literal: true

module Decidim
  module AttributeObject
    class NestedAttributes
      attr_reader :attributes

      delegate :each, :map, :keys, :values, :[], to: :attributes

      def initialize
        @attributes = {}
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
          key_type = options[:key_type]
          value_type = options[:value_type]

          value.map do |k, v|
            [value(k, key_type), value(v, value_type)]
          end.to_h
        elsif type == Array
          value_type = options[:value_type]

          value.map { |v| value(v, value_type) }
        else
          value(value, type)
        end
      end

      def value(raw, type)
        return unless raw
        return raw if raw.is_a?(type)
        return raw.to_s if type == String && raw.respond_to?(:to_s)
        return raw.to_i if type == Integer && raw.respond_to?(:to_i)

        type.new(raw)
      end
    end
  end
end
