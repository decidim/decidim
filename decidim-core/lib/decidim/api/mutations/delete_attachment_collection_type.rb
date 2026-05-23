# frozen_string_literal: true

module Decidim
  module Core
    class DeleteAttachmentCollectionType < Api::DestroyResourceType
      description "deletes an attachment collection"

      required_scopes "admin:read", "admin:write"

      type Decidim::Core::AttachmentType

      def authorized?(id:)
        attachment_collection = find_resource(id)
        unless super && allowed_to?(:destroy, :attachment_collection, attachment_collection, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def find_resource(id = nil)
        context[:attachment_collection] ||= begin
          id ||= arguments[:id]
          object.attachment_collections.find(id)
        end
      end
    end
  end
end
