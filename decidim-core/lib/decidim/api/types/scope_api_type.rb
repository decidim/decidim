# frozen_string_literal: true

module Decidim
  module Core
    class ScopeApiType < Decidim::Api::Types::BaseObject
      graphql_name "Scope"
      description "A scope"

      field :id, GraphQL::Types::ID, null: false
      field :name, Decidim::Core::TranslatedFieldType, "The graphql_name of this scope.", null: false

      field :children, [Decidim::Core::ScopeApiType, { null: true }], "Descendants of this scope", null: false
      field :parent, Decidim::Core::ScopeApiType, "This scope's parent scope.", null: true
    end
  end
end
