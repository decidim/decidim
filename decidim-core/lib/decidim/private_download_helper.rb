# frozen_string_literal: true

module Decidim
  module PrivateDownloadHelper
    def attach_archive(export_data, name, user)
      @export = user.private_exports.build
      @export.export_type = name
      @export.file.attach(io: StringIO.open(FileZipper.new(export_data.filename(name), export_data.read).zip), filename: "#{name}.zip")
      @export.expires_at = Decidim.download_your_data_expiry_time.from_now
      @export.metadata = {}
      @export.save!
      @export.reload
    end
  end
end
