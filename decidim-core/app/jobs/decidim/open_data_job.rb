# frozen_string_literal: true

module Decidim
  class OpenDataJob < ApplicationJob
    queue_as :exports

    def perform(organization, resource = nil)
      organization = Organization.with_attached_open_data_files.find(organization&.id)

      filename = organization.open_data_file_path(resource)
      path = Rails.root.join("tmp/#{filename}")

      exporter = OpenDataExporter.new(organization, path, resource)
      raise "Could not generate Open Data export" unless exporter.export.positive?

      organization.open_data_files.attach(io: File.open(path, "rb"), filename:)
      # Deletes the temporary file file
      File.delete(path)
    end
  end
end
