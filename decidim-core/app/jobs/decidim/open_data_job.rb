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

      File.open(path, "rb") do |file|
        organization.open_data_files.attach(io: file, filename:)
      end

      organization.open_data_files.select { |f| f.blob.filename.to_s == filename }.sort_by(&:created_at)[0...-1].each(&:purge)
    rescue StandardError => e
      Rails.logger.error "[OpenDataJob] Export failed for organization=#{organization&.id} resource=#{resource.inspect}: #{e.message}"
      raise
    ensure
      FileUtils.rm_f(path) if path.present?
    end
  end
end
