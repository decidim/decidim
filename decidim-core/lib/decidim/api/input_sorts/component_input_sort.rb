# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputSort < BaseInputSort
      include HasLocalizedInputSort

      graphql_name "ComponentSort"
      description "A type used for sorting any component parent objects"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
      argument :weight, GraphQL::Types::String, "Sort by weight (order in the website), valid values are ASC or DESC", required: false
      argument :type,
               type: GraphQL::Types::String,
               description: "Sort by type of component, alphabetically, valid values are ASC or DESC",
               required: false,
               as: :manifest_name
      argument :name,
               type: GraphQL::Types::String,
               description: "Sort by name of the component, alphabetically, valid values are ASC or DESC",
               required: false,
               as: :name,
               prepare: lambda { |direction, ctx|
                          lambda { |locale|
                            locale = ctx[:current_organization].default_locale if locale.blank?
                            field = Arel::Nodes::InfixOperation.new("->", Arel.sql("name"), Arel::Nodes.build_quoted(locale))
                            Arel::Nodes::InfixOperation.new("", field, Arel.sql(direction.upcase))
                          }
                        }
    end
  end
end
