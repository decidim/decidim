# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, export_format = ::Decidim::DataPortabilityExporter::DEFAULT_EXPORT_FORMAT)
      filename = "#{SecureRandom.urlsafe_base64}.zip"
      path = Rails.root.join("tmp/#{filename}")
      password = SecureRandom.urlsafe_base64

      generate_zip_file(user, path, password, export_format)
      save_or_upload_file(user, path)

      ExportMailer.data_portability_export(user, filename, password).deliver_later
    end

    private

    def generate_zip_file(user, path, password, export_format)
      DataPortabilityExporter.new(user, path, password, export_format).export
    end

    def save_or_upload_file(user, path)
      user.data_portability_file.attach(io: File.open(path, "rb"), filename: File.basename(path))
    end
  end
end
