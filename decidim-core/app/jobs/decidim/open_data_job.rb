# frozen_string_literal: true

module Decidim
  class OpenDataJob < ApplicationJob
    queue_as :exports

    def perform(organization, resource = nil)
      path = Rails.root.join("tmp/#{organization.open_data_file_path(resource)}")

      exporter = OpenDataExporter.new(organization, path, resource)
      raise "Could not generate Open Data export" unless exporter.export.positive?

      organization.open_data_files.attach(io: File.open(path, "rb"), filename: organization.open_data_file_path(resource))
      # Deletes the temporary file file
      File.delete(path)
    end
  end
end
