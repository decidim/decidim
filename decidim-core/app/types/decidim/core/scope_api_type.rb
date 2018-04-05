# frozen_string_literal: true

module Decidim
  module Core
    ScopeApiType = GraphQL::ObjectType.define do
      name "Scope"
      description "A scope"

      field :id, !types.ID
      field :name, !TranslatedFieldType, "The name of this scope."

      field :children, !types[Decidim::Core::ScopeApiType], "Descendants of this scope"
      field :parent, Decidim::Core::ScopeApiType, "This scope's parent scope."
    end
  end
end
