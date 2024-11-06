# frozen_string_literal: true

module Decidim
  class DownloadYourDataExportJob < ApplicationJob
    queue_as :default

    def perform(user, export_format = ::Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT)
      @export = DownloadYourDataExporter.new(user, "download_your_data", export_format).export
      ExportMailer.download_your_data_export(user, @export).deliver_later
    end
  end
end
