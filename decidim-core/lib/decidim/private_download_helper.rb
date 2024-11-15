# frozen_string_literal: true

module Decidim
  module PrivateDownloadHelper
    def attach_archive(export_data, name, user)
      private_exports = user.private_exports.build
      private_exports.export_type = name
      private_exports.file.attach(io: StringIO.open(FileZipper.new(export_data.filename(name), export_data.read).zip), filename: "#{name}.zip")
      private_exports.expires_at = Decidim.download_your_data_expiry_time.from_now
      private_exports.metadata = {}
      private_exports.save!
      private_exports.reload
    end
  end
end
