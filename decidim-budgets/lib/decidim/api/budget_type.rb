# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TraceableInterface

      description "A budget"

      field :id, GraphQL::Types::ID, "The internal ID of this budget", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this budget", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description for this budget", null: false
      field :total_budget, GraphQL::Types::Int, "The total budget", null: false, camelize: false
      field :created_at, Decidim::Core::DateTimeType, "When this budget was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this budget was updated", null: true

      field :projects, [Decidim::Budgets::ProjectType, { null: true }], "The projects for this budget", null: false
    end
  end
end
