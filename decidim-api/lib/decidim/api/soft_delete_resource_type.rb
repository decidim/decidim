# frozen_string_literal: true

module Decidim
  module Api
    class SoftDeleteResourceType < GraphQL::Schema::Mutation
      include Decidim::Api::GraphqlPermissions

      required_scopes "api:read", "api:write"

      description "Soft-deletes a resource: moves it to the 'trash', so it can be restored"

      argument :id, GraphQL::Types::ID, "The ID of the resource", required: true

      def resolve(id:)
        resource = find_resource(id)
        raise Decidim::Api::Errors::NotFoundError, "Resource not found" unless resource

        Decidim::Commands::SoftDeleteResource.call(resource, current_user) do
          on(:ok) do
            return resource
          end

          on(:invalid) do
            raise Decidim::Api::Errors::ValidationError, message
          end
        end
      end

      private

      def current_user
        context[:current_user]
      end

      def current_component
        context[:current_component]
      end

      def find_resource(id)
        raise NotImplementedError, "You must implement find_resource(id) in your mutation"
      end

      def trashable_deleted_resource_type
        raise NotImplementedError, "Return the type of the deleted resource (symbol)"
      end

      def human_readable_resource_name
        trashable_deleted_resource_type.to_s.humanize
      end

      def message
        I18n.t("soft_delete.invalid", scope: "decidim.admin.trash_management", resource_name: human_readable_resource_name)
      end
    end
  end
end
