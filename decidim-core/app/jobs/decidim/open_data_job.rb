# frozen_string_literal: true

module Decidim
  class OpenDataJob < ApplicationJob
    include Decidim::JobWithAssets

    queue_as :exports

    def perform(organization, resource = nil)
      path = nil
      organization = Organization.with_attached_open_data_files.find(organization&.id)

      filename = organization.open_data_file_path(resource)
      tmp_filename = "#{SecureRandom.uuid}-#{filename}"
      path = Rails.root.join("tmp", tmp_filename)

      Rails.logger.info "[OpenDataJob] Starting export for organization=#{organization.id} resource=#{resource.inspect}"

      exporter = OpenDataExporter.new(organization, path, resource)
      exported_bytes = exporter.export

      raise "Export produced no data (0 bytes) for resource=#{resource.inspect}" unless exported_bytes.is_a?(Integer) && exported_bytes.positive?

      publish_export(organization, filename, path)
    rescue StandardError => e
      Rails.logger.error "[OpenDataJob] Export failed for organization=#{organization&.id} resource=#{resource.inspect}: #{e.message}"
      raise
    ensure
      FileUtils.rm_f(path) if path.present?
    end

    private

    def publish_export(organization, filename, path)
      # The blob is uploaded before the lock so that a storage failure cannot leave the
      # organization without a downloadable export: the previous file is only replaced
      # once the new bytes are safely stored.
      File.open(path, "rb") do |file|
        blob = ActiveStorage::Blob.create_and_upload!(io: file, filename:, record: organization)

        stale_blobs = publish_blob(organization, filename, blob)

        # Blobs are purged after the transaction commits, so a rollback cannot leave
        # attachment rows pointing to deleted files.
        stale_blobs.each(&:purge)
      rescue StandardError => e
        # Best-effort cleanup: if publication did not commit, the uploaded replacement
        # is orphaned; clean it up so a retry does not leave an unreferenced blob
        # behind. A committed replacement must be preserved, and the original error
        # must not be masked by the cleanup.
        begin
          blob.purge if blob && !blob.attachments.exists?
        rescue StandardError
          nil
        end
        raise e
      end
    end

    def publish_blob(organization, filename, blob)
      # Publishing is serialized per organization: concurrent jobs would otherwise work
      # on the attachment snapshot preloaded before the export, creating duplicate
      # attachments for the same blob and leaving the controller serving an older file.
      # The winner is decided by publication order, not by the order in which the data
      # snapshots were generated: the last published attachment is the one kept.
      organization.with_lock do
        organization.open_data_files.reload

        organization.open_data_files.attach(blob)

        stale = organization.open_data_files.select { |f| f.blob.filename.to_s == filename }.sort_by(&:created_at)[0...-1]
        stale.each(&:delete)
        stale.map(&:blob)
      end
    end
  end
end
