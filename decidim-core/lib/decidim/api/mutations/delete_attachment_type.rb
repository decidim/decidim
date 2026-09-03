# frozen_string_literal: true

module Decidim
  module Core
    class DeleteAttachmentType < Api::DestroyResourceType
      description "Deletes an attachment"

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
        @attachment ||= begin
          id ||= arguments[:id]
          object.attachments.find(id)
        end
      end
    end
  end
end
