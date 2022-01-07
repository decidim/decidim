# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent a Symbol.
    class Symbol < ActiveModel::Type::Value
      def type # :nodoc:
        :symbol
      end

      private

      def cast_value(value)
        return value if value.is_a?(::Symbol)

        value = value.to_s if !value.respond_to?(:to_sym) && value.respond_to?(:to_s)
        return unless value.respond_to?(:to_sym)

        value.to_sym
      end
    end
  end
end
