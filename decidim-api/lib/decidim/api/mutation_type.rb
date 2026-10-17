# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root mutation type of the whole API
    class MutationType < Decidim::Api::Types::BaseObject
      description "The root mutation of this schema"

      required_scopes "api:write"

      field :component, Decidim::Api::ComponentMutationType, "The component of this schema", null: false do
        argument :id, GraphQL::Types::ID, "The Comment's unique ID", required: true
      end

      field :delete_blob, mutation: Decidim::Core::DeleteBlobType, description: "Delete a blob"
      field :upload_file, mutation: Decidim::Core::UploadFileType, description: "Upload a file"

      def component(id:)
        current_organization&.published_components&.find(id)
      end
    end
  end
end
