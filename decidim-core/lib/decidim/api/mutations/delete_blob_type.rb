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

        attachments = resource.attachments.to_a
        unless attachments.empty?
          attachments.each do |attachment|
            record = attachment.record
            # Only the records which represent the uploaded file itself are removed
            # with the blob. Destroying just the Active Storage join records would
            # leave a `Decidim::Attachment` without a file, and its `url` and `type`
            # GraphQL fields would then return null. The other records (e.g. an
            # organization favicon) keep their row and only lose the file reference.
            record.is_a?(Decidim::Attachment) ? record.destroy : attachment.destroy
          end
          resource.purge
          return resource
        end

        # An unattached blob has no organization to authorize against, so it is
        # rejected here instead of being purged, otherwise an admin from any
        # organization could delete the unattached uploads of another one.
        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.not_attached")
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
