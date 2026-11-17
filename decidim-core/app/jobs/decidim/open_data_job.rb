# frozen_string_literal: true

module Decidim
  class OpenDataJob < ApplicationJob
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

      # The export is generated outside the lock, but publishing it is serialized per
      # organization: concurrent jobs would otherwise work on the attachment snapshot
      # preloaded before the export, creating duplicate attachments for the same blob
      # and leaving the controller serving an older file. The lock stays inside the
      # `File.open` block because ActiveStorage uploads in an `after_commit` callback,
      # which runs while the transaction commits.
      File.open(path, "rb") do |file|
        organization.with_lock do
          organization.open_data_files.reload

          organization.open_data_files.attach(io: file, filename:)

          organization.open_data_files.select { |f| f.blob.filename.to_s == filename }.sort_by(&:created_at)[0...-1].each(&:purge)
        end
      end
    rescue StandardError => e
      Rails.logger.error "[OpenDataJob] Export failed for organization=#{organization&.id} resource=#{resource.inspect}: #{e.message}"
      raise
    ensure
      FileUtils.rm_f(path) if path.present?
    end
  end
end
