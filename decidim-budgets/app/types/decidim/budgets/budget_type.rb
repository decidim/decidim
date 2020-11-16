# frozen_string_literal: true

module Decidim
  module Budgets
    BudgetType = GraphQL::ObjectType.define do
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      name "Budget"
      description "A budget"

      field :id, !types.ID, "The internal ID of this budget"
      field :title, !Decidim::Core::TranslatedFieldType, "The title for this budget"
      field :description, !Decidim::Core::TranslatedFieldType, "The description for this budget"
      field :total_budget, !types.Int, "The total budget"

      field :projects, !types[Decidim::Budgets::ProjectType], "The projects for this budget"
    end
  end
end
