# frozen_string_literal: true

module Decidim
  # This module extends the API with custom fields related to decidim-core.
  module MutationExtensions
    def self.included(type)
      type.field :component, Decidim::Api::ComponentMutationType, "The component of this schema", null: false do
        argument :id, GraphQL::Types::ID, "The Comment's unique ID", required: true
      end

      type.field :delete_blob, mutation: Decidim::Core::DeleteBlobType, description: "Delete a blob"
    end

    def component(id:)
      Decidim::Component.find(id)
    end
  end
end
