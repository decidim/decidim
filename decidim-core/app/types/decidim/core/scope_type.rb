# frozen_string_literal: true

module Decidim
  module Core
    ScopeType = GraphQL::ObjectType.define do
      name "Scope"
      description "A scope"

      field :id, !types.ID
      field :name, !TranslatedFieldType, "The name of this scope."

      field :children, !types[Decidim::Core::ScopeType], "Descendants of this scope"
      field :parent, Decidim::Core::ScopeType, "This scope's parent scope."
    end
  end
end
