# frozen_string_literal: true

module Decidim
  module Core
    # The file attributes can be used outside of this module for the GraphQL
    # mutations that need to work with attaching or detaching files to different
    # objects.
    class FileInputObject < Decidim::Api::Types::BaseInputObject
      include Decidim::Core::BlobOrganization

      description "Attributes for attaching files to objects"

      argument :signed_id, GraphQL::Types::String, description: "The signed ID of the file blob to attach to the object", required: true

      def blob
        return unless signed_id

        raise Api::Errors::UnauthorizedObjectError, "You do not have permission to access this blob" unless context[:current_user]&.admin?

        # `find_signed` does not raise: it returns nil when the signed ID has been
        # tampered with, has a purpose mismatch or has expired, and when the blob
        # does not exist anymore. The blob must be resolved before it is used for
        # the organization check.
        blob = ActiveStorage::Blob.find_signed(signed_id)
        raise Api::Errors::NotFoundError, I18n.t("decidim.api.errors.not_found", type: "Blob") unless blob

        # A blob can only be used when every record already using it belongs to the
        # current organization. An upload which is not attached to any record yet
        # has no organization to check against, so it is accepted here and becomes
        # owned by the record it is attached to.
        raise Api::Errors::UnauthorizedObjectError, "You do not have permission to access this blob" unless attached_to_current_organization?(blob)

        blob
      end
    end
  end
end
