# frozen_string_literal: true

module Decidim
  module Budgets
    ProjectType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::CategorizableInterface }
      ]

      name "Project"
      description "A project"

      field :id, !types.ID, "The internal ID for this project"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this project"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this project"
      field :budget_amount, types.Int, "The budget amount for this project"
      field :createdAt, Decidim::Core::DateTimeType, "When this project was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "When this project was updated", property: :updated_at
      field :reference, types.String, "The reference for this project"
    end
  end
end
