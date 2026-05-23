# frozen_string_literal: true

module Decidim
  module Core
    class DeleteAttachmentType < Api::DestroyResourceType
      description "deletes an attachment"

      required_scopes "admin:read", "admin:write"

      type Decidim::Core::AttachmentType

      def authorized?(id:)
        attachment = find_resource(id)
        unless super && allowed_to?(:delete, :attachment, attachment, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def find_resource(id = nil)
        context[:attachment] ||= begin
          id ||= arguments[:id]
          Decidim::Attachment.find(id)
        end
      end
    end
  end
end
