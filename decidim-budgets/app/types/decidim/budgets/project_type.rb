# frozen_string_literal: true

module Decidim
  module Budgets
    ProjectType = GraphQL::ObjectType.define do
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::TimestampsInterface

      name "Project"
      description "A project"

      field :id, !types.ID, "The internal ID for this project"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this project"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this project"
      field :budget_amount, types.Int, "The budget amount for this project"
      field :selected, types.Boolean, "Whether this proposal is selected or not", property: :selected?
      field :reference, types.String, "The reference for this project"
    end
  end
end
