# frozen_string_literal: true

module Decidim
  class OpenDataJob < ApplicationJob
    queue_as :exports

    def perform(organization)
      path = Rails.root.join("tmp/#{organization.open_data_file_path}")

      exporter = OpenDataExporter.new(organization, path)
      raise "Couldn't generate Open Data export" unless exporter.export.positive?

      OpenDataUploader.new(organization).store!(File.open(path, "rb"))
    end
  end
end
