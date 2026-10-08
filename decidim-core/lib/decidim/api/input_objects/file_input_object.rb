# frozen_string_literal: true

module Decidim
  module Core
    # The file attributes can be used outside of this module for the GraphQL
    # mutations that need to work with attaching or detaching files to different
    # objects.
    class FileInputObject < Decidim::Api::Types::BaseInputObject
      description "Attributes for attaching files to objects"

      argument :signed_id, GraphQL::Types::String, description: "The signed ID of the file blob to attach to the object", required: true

      def blob
        return unless signed_id

        blob = ActiveStorage::Blob.find_signed(signed_id)
        raise Api::Errors::UnauthorizedObjectError, "You do not have permission to access this blob" unless context[:current_user]&.admin?

        blob
      end
    end
  end
end
