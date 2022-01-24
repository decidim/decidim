# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to represent an Object.
    class Object < ActiveModel::Type::Value
      attr_reader :primitive

      def initialize(primitive: ::Object)
        @primitive = primitive
      end

      def type # :nodoc:
        :object
      end

      # The nested validator should be only added for those attributes that
      # inherit from the AttributeObject::Model type. Otherwise this would be
      # also added e.g. for ActiveRecord objects which would cause unexpected
      # validation errors.
      def validate_nested?
        return false unless primitive.is_a?(Class)

        (primitive < Decidim::AttributeObject::Model) == true
      end
    end
  end
end
