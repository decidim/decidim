# frozen_string_literal: true

module Decidim
  module Core
    class BaseInputSort < GraphQL::Schema::InputObject
      # Overwrite the prepare method to allow 2 possible values only
      def prepare
        arguments.each do |key, value|
          next if key == "locale"
          raise GraphQL::ExecutionError, "Invalid order value for #{key}, only ASC or DESC are valids" unless valid_order?(value)
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
