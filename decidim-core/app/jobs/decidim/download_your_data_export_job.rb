# frozen_string_literal: true

module Decidim
  class DownloadYourDataExportJob < ApplicationJob
    include Decidim::PrivateDownloadHelper

    queue_as :default

    def perform(user, export_format = ::Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT)
      filename = "#{SecureRandom.urlsafe_base64}.zip"
      path = Rails.root.join("tmp/#{filename}")

      generate_zip_file(user, path, export_format)
      save_or_upload_file(user, "download_your_data", path)
      # Deletes temporary file
      File.delete(path)
      ExportMailer.download_your_data_export(user, @export).deliver_later
    end

    private

    def generate_zip_file(user, path, export_format)
      DownloadYourDataExporter.new(user, path, export_format).export
    end
  end
end
