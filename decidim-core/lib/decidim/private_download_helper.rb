# frozen_string_literal: true

module Decidim
  module PrivateDownloadHelper

    def attach_archive(export_data, name, user)
      path = Rails.root.join("tmp/#{SecureRandom.urlsafe_base64}.zip")
      export_data.read
      File.binwrite(path, FileZipper.new(export_data.filename(name), export_data.read).zip)

      save_or_upload_file(user, name, path)

      File.delete(path)
    end

    def save_or_upload_file(user, name, path, metadata = {})
      @export = user.private_exports.build
      @export.export_type = name
      @export.file.attach(io: File.open(path, "rb"), filename: File.basename(path))
      @export.expires_at = Decidim.download_your_data_expiry_time.from_now
      @export.metadata = metadata
      @export.save!
      @export.reload
    end

  end
end
