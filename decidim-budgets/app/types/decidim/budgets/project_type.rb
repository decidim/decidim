# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface

      description "A project"

      field :id, ID, "The internal ID for this project", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this project", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this project", null: true
      field :budget_amount, Integer, "The budget amount for this project", null: true, camelize: false
      field :selected, Boolean, "Whether this proposal is selected or not", method: :selected?, null: true
      field :created_at, Decidim::Core::DateTimeType, "When this project was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this project was updated", null: true
      field :reference, String, "The reference for this project", null: true
    end
  end
end
