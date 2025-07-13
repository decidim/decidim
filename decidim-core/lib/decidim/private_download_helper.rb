# frozen_string_literal: true

module Decidim
  module PrivateDownloadHelper
    def attach_archive(export_data, file_name, user, export_type = nil)
      private_exports = user.private_exports.build
      private_exports.export_type = export_type || file_name
      private_exports.file.attach(io: StringIO.open(FileZipper.new(export_data.filename(file_name), export_data.read).zip), filename: "#{file_name}.zip")
      private_exports.expires_at = Decidim.download_your_data_expiry_time.from_now
      private_exports.metadata = {}
      private_exports.save!
      private_exports.reload
    end
  end
end
