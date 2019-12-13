# frozen_string_literal: true

module Decidim
  module Core
    class BaseInputSort < GraphQL::Schema::InputObject
      def prepare
        arguments.each do |key, value|
          raise GraphQL::ExecutionError, "Invalid order value for #{key}, only ASC or DESC are valids" unless valid_order?(value)
        end
      end

      private

      def valid_order?(order)
        %w(asc desc).include? order.downcase
      end
    end
  end
end
