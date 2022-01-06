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
        return value unless value.is_a?(::Symbol)

        value.to_sym
      end
    end
  end
end
