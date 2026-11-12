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
          # The private download requirement comes from the record the blob is
          # attached to. Once those records are destroyed the type can no longer
          # detect it, so the attachment is remembered before the purge; without
          # it `src` and `signed_id` fall back to the direct Active Storage url,
          # a bearer credential which keeps working until the purge job runs.
          private_download_attachment = attachments.find do |attachment|
            record = attachment.record
            record.respond_to?(:private_download_required?) && record.private_download_required?
          end

          attachments.each do |attachment|
            record = attachment.record
            # Only the records which represent the uploaded file itself are removed
            # with the blob. Destroying just the Active Storage join records would
            # leave a `Decidim::Attachment` without a file, and its `url` and `type`
            # GraphQL fields would then return null. The other records (e.g. an
            # organization favicon) keep their row and only lose the file reference.
            record.is_a?(Decidim::Attachment) ? record.destroy : attachment.destroy
          end

          # The context is shared by every field of the operation, so the
          # attachment is stored per blob. An unkeyed value would also be used by
          # another mutation in the same operation (e.g. `uploadFile`), which has
          # no attachments of its own and would then report this file's private
          # download url instead of its own signed id.
          context[:private_download_attachments] = (context[:private_download_attachments] || {}).merge(resource.id => private_download_attachment)

          resource.purge_later
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
