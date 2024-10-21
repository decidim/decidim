# frozen_string_literal: true

module Decidim
  class DownloadYourDataExportJob < ApplicationJob
    queue_as :default

    def perform(user, export_format = ::Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT)
      filename = "#{SecureRandom.urlsafe_base64}.zip"
      path = Rails.root.join("tmp/#{filename}")
      password = SecureRandom.urlsafe_base64

      generate_zip_file(user, path, password, export_format)
      save_or_upload_file(user, path)
      # Deletes temporary file
      File.delete(path)
      ExportMailer.download_your_data_export(user, @export, password).deliver_later
    end

    private

    def generate_zip_file(user, path, password, export_format)
      DownloadYourDataExporter.new(user, path, password, export_format).export
    end

    def save_or_upload_file(user, path)
      @export = user.private_exports.build
      @export.export_type = "download_your_data"
      @export.file.attach(io: File.open(path, "rb"), filename: File.basename(path))
      @export.expires_at = Decidim.download_your_data_expiry_time.from_now
      @export.save!
    end
  end
end
