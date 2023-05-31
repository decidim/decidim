# frozen_string_literal: true

module Decidim
  module AttributeObject
    class NestedValidator < ActiveModel::EachValidator # :nodoc:
      def validate_each(record, attribute, value)
        value = value.values if value.is_a?(Hash)
        return unless Array(value).reject { |r| valid_object?(r) }.any?

        record.errors.add(attribute, :invalid, **options.merge(value:))
      end

      private

      def valid_object?(record)
        return true unless record.respond_to?(:valid?)

        record.valid?
      end
    end
  end
end
