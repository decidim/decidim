# frozen_string_literal: true

module Decidim
  module Attributes
    class IntegerWithUnits < ActiveModel::Type::Value
      def type
        :"decidim/attributes/integer_with_units"
      end

      def cast(value)
        byebug
        value = value.to_a if value.respond_to?(:to_a)
        value = [value[0].to_i, value[1].to_s] if value.is_a?(Array) && value.size == 2

        value
      end
    end
  end
end
