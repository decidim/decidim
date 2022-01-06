# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent a Model.
    class Model < Decidim::Attributes::Object
      def type # :nodoc:
        :model
      end

      private

      def cast_value(value)
        return value if value.is_a?(Decidim::AttributeObject::Model)
        return value if value.is_a?(ActiveRecord::Base)
        return primitive.new(value) if value.is_a?(::Hash)
        return primitive.new(value.to_h) if value.respond_to?(:to_h)
        return primitive.new(value.attributes) if value.respond_to?(:attributes)

        value
      end
    end
  end
end
