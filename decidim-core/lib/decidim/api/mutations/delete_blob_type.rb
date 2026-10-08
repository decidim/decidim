# frozen_string_literal: true

module Decidim
  module Core
    class DeleteBlobType < Api::DestroyResourceType
      description "Deletes a blob"

      required_scopes "api:read", "admin:read", "admin:write"

      type Decidim::Core::BlobType

      def resolve(id:)
        resource = find_resource(id)

        if resource.respond_to?(:attachments) && resource.attachments.any?
          resource.attachments.destroy_all
          resource.purge
          return resource
        end

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
        context[:blob] ||= begin
          id ||= arguments[:id]
          ActiveStorage::Blob.find(id)
        end
      end

      def current_organization
        context[:current_organization]
      end

      # Blobs are not organization scoped on their own, their ownership is
      # derived from the records they are attached to. Every record using the
      # blob must belong to the current organization, otherwise an admin from
      # one organization could destroy files attached to records of another
      # organization.
      def attached_to_current_organization?(blob)
        records = blob.attachments.map(&:record).compact
        # Blobs without attachments are rejected in `resolve` with a
        # validation error, as there is nothing to detach or destroy here.
        return true if records.empty?

        records.all? { |record| record_organization(record) == current_organization }
      end

      def record_organization(record)
        return record if record.is_a?(Decidim::Organization)
        return unless record.respond_to?(:organization)

        record.organization
      end
    end
  end
end
