# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputSort < BaseInputSort
      include HasLocalizedInputSort

      graphql_name "ComponentSort"
      description "A type used for sorting any component parent objects"

      argument :id, String, "Sort by ID, valid values are ASC or DESC", required: false
      argument :weight, String, "Sort by weight (order in the website), valid values are ASC or DESC", required: false
      argument :type,
               type: String,
               description: "Sort by type of component, alphabetically, valid values are ASC or DESC",
               required: false,
               prepare: ->(direction, _ctx) do
                 { manifest_name: direction }
               end
      argument :name,
               type: String,
               description: "Sort by name of the component, alphabetically, valid values are ASC or DESC",
               required: false,
               prepare: ->(direction, ctx) do
                          proc do |locale|
                            locale = ctx[:current_organization].default_locale if locale.blank?
                            [Arel.sql("name->? #{direction.upcase}"), locale]
                          end
                        end
    end
  end
end
