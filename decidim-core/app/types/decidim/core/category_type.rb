# frozen_string_literal: true

module Decidim
  module Core
    CategoryType = GraphQL::ObjectType.define do
      name "Category"
      description "A category that can be applied to other resources."

      field :id, !types.ID
      field :name, !TranslatedFieldType, "The name of this category."

      field :subcategories, !types[Decidim::Core::CategoryType], "Subcategories of this category."
      field :parent, Decidim::Core::CategoryType, "This category's parent category."
    end
  end
end
