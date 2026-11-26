# frozen_string_literal: true

module Decidim
  module Core
    class DeleteBlobType < Api::DestroyResourceType
      include Decidim::Core::BlobOrganization

      description "Deletes a blob"

      required_scopes "api:read", "admin:read", "admin:write"

      type Decidim::Core::BlobType

      def resolve(id:)
        resource = find_resource(id)

        private_download_attachment = resource.attachments.to_a.find do |attachment|
          record = attachment.record
          record.respond_to?(:private_download_required?) && record.private_download_required?
        end

        Decidim::Commands::DeleteBlob.call(resource, current_user) do
          on(:ok) do
            context[:private_download_attachments] = (context[:private_download_attachments] || {}).merge(resource.id => private_download_attachment)

            return resource
          end

          on(:invalid) do
            raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.not_attached")
          end
        end
      end

      def authorized?(id:)
        blob = find_resource(id)
        unless super && allowed_to?(:delete, :blob, blob, context) && attached_to_current_organization?(blob)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def find_resource(id = nil)
        @blob ||= begin
          id ||= arguments[:id]
          ActiveStorage::Blob.find(id)
        end
      end
    end
  end
end
