# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent an Integer that is customized from
    # the parent class to also convert records to their ID representations.
    class Integer < ActiveModel::Type::Integer
      private

      def cast_value(value)
        return cast_value(value.id) if value.respond_to?(:id)

        super
      end
    end
  end
end
