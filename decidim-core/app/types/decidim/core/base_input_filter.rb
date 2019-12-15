# frozen_string_literal: true

module Decidim
  module Core
    class BaseInputFilter < GraphQL::Schema::InputObject
      argument :locale,
               type: String,
               description: "Specify the locale to use when searching translated fields, otherwise default organization language will be used",
               required: false,
               prepare: ->(locale, ctx) do
                 raise GraphQL::ExecutionError, "#{locale} locale is not used in the organization" unless ctx[:current_organization].available_locales.include?(locale)

                 locale
               end
    end
  end
end
