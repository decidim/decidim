# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent an Integer with units.
    class IntegerWithUnits < ActiveModel::Type::Value
      def type
        :"decidim/attributes/integer_with_units"
      end

      def cast(value)
        return nil if value.nil?

        case value
        when ::Hash
          [value["0"].to_i.abs, value["1"].to_s]
        when ::Array
          return value if value.size != 2

          [value[0].to_i.abs, value[1].to_s]
        else
          value
        end
      end
    end
  end
end
