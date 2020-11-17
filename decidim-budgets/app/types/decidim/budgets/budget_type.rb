# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetType < GraphQL::Schema::Object
      graphql_name "Budget"
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      description "A budget"

      field :id, ID, null: false, description: "The internal ID of this budget"
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title for this budget"
      field :description, Decidim::Core::TranslatedFieldType, null: false, description: "The description for this budget"
      field :total_budget, Int, null: false, description: "The total budget"

      field :projects, [Decidim::Budgets::ProjectType], null: false, description: "The projects for this budget"
    end
  end
end
