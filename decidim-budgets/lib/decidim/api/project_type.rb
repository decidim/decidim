# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface

      description "A project"

      field :id, GraphQL::Types::ID, "The internal ID for this project", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this project", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this project", null: true
      field :budget_amount, GraphQL::Types::Int, "The budget amount for this project", null: true, camelize: false
      field :selected, GraphQL::Types::Boolean, "Whether this proposal is selected or not", method: :selected?, null: true
      field :reference, GraphQL::Types::String, "The reference for this project", null: true

      def self.authorized?(object, context)
        context[:project] = object

        chain = [
          allowed_to?(:read, :project, object, context),
          object.visible?
        ].all?

        super && chain
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
