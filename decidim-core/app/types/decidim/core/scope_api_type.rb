# frozen_string_literal: true

module Decidim
  module Core
    class ScopeApiType < GraphQL::Schema::Object
      graphql_name "Scope"
      description "A scope"

      field :id, ID, null: false, description: "Internal ID for this scope"
      field :name, TranslatedFieldType, null: false, description: "The name of this scope."

      field :children, [Decidim::Core::ScopeApiType], null: false, description: "Descendants of this scope"
      field :parent, Decidim::Core::ScopeApiType, null: true, description: "This scope's parent scope."
    end
  end
end
