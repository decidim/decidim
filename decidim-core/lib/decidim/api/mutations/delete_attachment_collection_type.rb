# frozen_string_literal: true

module Decidim
  module Core
    class DeleteAttachmentCollectionType < Api::DestroyResourceType
      description "Deletes an attachment collection"

      type Decidim::Core::AttachmentCollectionType

      # Managing attachment collections is an administrative action, so the OAuth
      # token must have been granted the administrative scopes, in the same way as
      # the upload mutation and the existing result and project mutations. These
      # scopes also make `api_scope` return `:admin`, so the permission check is
      # done against the administrative permissions.
      required_scopes "api:read", "api:write", "admin:read", "admin:write"

      def authorized?(id:)
        attachment_collection = find_resource(id)
        unless super && allowed_to?(:destroy, :attachment_collection, attachment_collection, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def find_resource(id = nil)
        @attachment_collection ||= begin
          id ||= arguments[:id]
          object.attachment_collections.find(id)
        end
      end
    end
  end
end
