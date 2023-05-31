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
        return value if value.is_a?(primitive)
        return value if value.is_a?(Decidim::AttributeObject::Model)
        return primitive.new(value) if value.is_a?(::Hash)
        return primitive.new(value.to_h) if value.respond_to?(:to_h)

        if value.respond_to?(:attributes)
          # In case the primitive is a form object, we also need to call the
          # `map_model` method in case the target form object defines it for
          # nested forms to work properly.
          converted = primitive.new(value.attributes)
          converted.map_model(value) if converted.respond_to?(:map_model)
          return converted
        end

        value
      end
    end
  end
end
