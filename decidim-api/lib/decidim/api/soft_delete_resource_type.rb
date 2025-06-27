# frozen_string_literal: true

module Decidim
  module Api
    class SoftDeleteResourceType < GraphQL::Schema::Mutation
      include Decidim::Api::GraphqlPermissions

      description "soft-deletes a resource"

      argument :id, GraphQL::Types::ID, "The ID of the resource", required: true

      def resolve(id:)
        resource = find_resource(id)
        current_user = context[:current_user]

        Decidim::Commands::SoftDeleteResource.call(resource, current_user) do
          on(:ok) do
            return resource
          end

          on(:invalid) do
            return GraphQL::ExecutionError.new(
              I18n.t(
                "soft_delete.invalid",
                scope: "decidim.admin.trash_management",
                resource_name: human_readable_resource_name
              )
            )
          end
        end
      end

      private

      def find_resource(id)
        raise NotImplementedError, "You must implement find_resource(id) in your mutation"
      end

      def trashable_deleted_resource_type
        raise NotImplementedError, "Return the type of the deleted resource (symbol)"
      end
    end
  end
end
