# frozen_string_literal: true

module Decidim
  module Core
    # Blobs are not organization scoped on their own, their ownership is derived
    # from the records they are attached to, the same way `Decidim::Attachment#organization`
    # derives it from `attached_to`. Every API entry point which receives a blob
    # identifier from the client must check that all the records using it belong
    # to the current organization, otherwise an admin from one organization could
    # use the files attached to the records of another organization.
    module BlobOrganization
      private

      def current_organization
        context[:current_organization]
      end

      # Whether every record using the blob belongs to the current organization.
      #
      # A blob without attachments has no record to derive the organization from,
      # so it cannot be attributed to any organization and is accepted here: it is
      # an upload which is not attached to a record yet. The entry points which
      # cannot accept unattached blobs (like `DeleteBlobType`) reject them
      # separately, and the abandoned uploads are removed by the
      # `decidim:attachments_cleanup` scheduled task.
      def attached_to_current_organization?(blob)
        records = blob.attachments.map(&:record).compact
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
