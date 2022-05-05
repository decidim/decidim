# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent a Hash.
    class Hash < Decidim::Attributes::Array
      attr_reader :key_type

      def initialize(key_type: ::Symbol, value_type: ::Object, default: {})
        @key_type = key_type
        @value_type = value_type
        @default = default
      end

      def type # :nodoc:
        :hash
      end

      private

      def cast_value(value)
        value ||= default.dup
        value = value.to_h if !value.is_a?(::Hash) && value.respond_to?(:to_h)

        # This preserves backwards compatibility for non-hash values e.g. with
        # the admin hero content block which expects the images container object
        # as the default value when building the admin form.
        return value unless value.is_a?(::Hash)

        value.to_h do |k, v|
          [primitive_value(k, key_type), primitive_value(v, value_type)]
        end
      end
    end
  end
end
