# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectType < GraphQL::Schema::Object
      graphql_name "Project"
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::TimestampsInterface

      description "A project"

      field :id, ID, null: false, description: "The internal ID for this project"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The title for this project"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for this project"
      field :budget_amount, Int, null: true, description: "The budget amount for this project"
      field :selected, Boolean, null: true, description: "Whether this proposal is selected or not" do
        def resolve(object:, _args:, context:)
          object.selected?
        end
      end
      field :reference, String, null: true, description: "The reference for this project"
    end
  end
end
