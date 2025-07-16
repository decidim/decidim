# frozen_string_literal: true

module Decidim
  module Api
    class DestroyResourceType < GraphQL::Schema::Mutation
      include Decidim::Api::GraphqlPermissions

      description "deletes a resource"

      argument :id, GraphQL::Types::ID, "The ID of the resource", required: true

      def resolve(id:)
        resource = find_resource(id)
        current_user = context[:current_user]

        Decidim::Commands::DestroyResource.call(resource, current_user) do
          on(:ok, resource) do
            return resource
          end
        end
      end

      private

      def find_resource(id)
        raise NotImplementedError, "You must implement find_resource(id) in your mutation"
      end
    end
  end
end
