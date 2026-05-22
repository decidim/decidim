# frozen_string_literal: true

module Decidim
  module Api
    class DestroyResourceType < GraphQL::Schema::Mutation
      include Decidim::Api::GraphqlPermissions

      required_scopes "api:read", "api:write"

      description "deletes a resource"

      argument :id, GraphQL::Types::ID, "The ID of the resource", required: true

      def resolve(id:)
        resource = find_resource(id)

        Decidim::Commands::DestroyResource.call(resource, current_user) do
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

      def find_resource(id)
        raise NotImplementedError, "You must implement find_resource(id) in your mutation"
      end
    end
  end
end
