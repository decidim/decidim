# frozen_string_literal: true

module Decidim
  module Core
    class BaseInputSort < GraphQL::Schema::InputObject
      argument :locale,
               type: String,
               description: "Specify the locale to use when ordering translated fields, otherwise default organization language will be used",
               required: false,
               prepare: ->(locale, ctx) do
                 raise GraphQL::ExecutionError, "#{locale} locale is not used in the organization" unless ctx[:current_organization].available_locales.include?(locale)

                 locale
               end

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
