# frozen_string_literal: true

module Decidim
  module Core
    class BaseInputSort < GraphQL::Schema::InputObject
      # Overwrite the prepare method to allow 2 possible values only
      def prepare
        arguments.each do |key, value|
          next if key.to_s == "locale"
          next if value.respond_to?(:call)
          raise GraphQL::ExecutionError, "Invalid order value for #{key.inspect}, only ASC or DESC are valids (received #{value.inspect})" unless valid_order?(value)
        end
        super
      end

      private

      def valid_order?(order)
        %w(asc desc).include? order.downcase
      end
    end
  end
end
