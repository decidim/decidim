# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, export_format)
      filename = "#{SecureRandom.urlsafe_base64}.zip"
      path = Rails.root.join("tmp/#{filename}")
      password = SecureRandom.urlsafe_base64

      DataPortabilityExporter.new(user, path, export_format, password).export
      DataPortabilityUploader.new.store!(File.open(path, "rb"))
      ExportMailer.data_portability_export(user, filename, password).deliver_later
    end
  end
end
