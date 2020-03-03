# frozen_string_literal: true

module Decidim
  module Core
    module HasLocalizedInputSort
      def self.included(child_class)
        child_class.argument :locale,
                             type: String,
                             description: "Specify the locale to use when ordering translated fields, otherwise default organization language will be used",
                             required: false,
                             prepare: ->(locale, ctx) do
                               unless ctx[:current_organization].available_locales.include?(locale)
                                 raise GraphQL::ExecutionError, "#{locale} locale is not used in the organization"
                               end

                               locale
                             end
      end
    end
  end
end
