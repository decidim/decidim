# frozen_string_literal: true

module Decidim
  module Core
    class CategoryType  < GraphQL::Schema::Object
      graphql_name  "Category"
      description "A category that can be applied to other resources."

      field :id, ID, null: false, description: "Internal ID for this category"
      field :name, TranslatedFieldType, null: false, description: "The name of this category."

      field :subcategories, [Decidim::Core::CategoryType],null: false, description:  "Subcategories of this category."
      field :parent, Decidim::Core::CategoryType, null: true, description: "This category's parent category."
    end
  end
end
