# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectMutationType < Decidim::Api::Types::BaseObject
      description "Project mutations"
      graphql_name "ProjectMutation"

      include Decidim::Core::AttachableMutations
      include Decidim::Core::AttachableCollectionMutations

      field :delete, mutation: Decidim::Budgets::DeleteProjectType, description: "Deletes a project"
      field :update, mutation: Decidim::Budgets::UpdateProjectType, description: "Updates a project"

      def initialize(object, context)
        context.scoped_set!(:scope, :admin) if context[:current_user]
        @object = object
        @context = context
      end
    end
  end
end
