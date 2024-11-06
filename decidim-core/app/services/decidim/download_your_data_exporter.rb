# frozen_string_literal: true

module Decidim
  # Public: Generates a zip archive with data files ready to be persisted
  # somewhere so users can download their data.
  #
  class DownloadYourDataExporter
    DEFAULT_EXPORT_FORMAT = "CSV"
    ZIP_FILE_NAME = "download-your-data.zip"

    # Public: Initializes the class.
    #
    # user          - The user to export the data from.
    # name          - The name of the export in private area
    # export_format - The format of the data files inside the zip file. (CSV by default)
    def initialize(user, name, export_format = DEFAULT_EXPORT_FORMAT)
      @user = user
      @export_format = export_format
      @name = name
    end

    def export
      user_export = user.private_exports.build
      user_export.export_type = name
      user_export.file.attach(io: data, filename: "#{name}.zip", content_type: "application/zip")
      user_export.expires_at = Decidim.download_your_data_expiry_time.from_now
      user_export.metadata = {}
      user_export.save!
      user_export
    end

    private

    attr_reader :user, :export_format, :name

    def data
      user_data, user_attachments = data_and_attachments_for_user
      buffer = Zip::OutputStream.write_buffer do |out|
        save_user_data(out, user_data)
        save_user_attachments(out, user_attachments)
      end

      buffer.rewind
      buffer
    end

    def data_and_attachments_for_user
      export_data = []
      export_attachments = []

      download_your_data_entities.each do |object|
        klass = Object.const_get(object)
        export_data << [klass.model_name.name.parameterize.pluralize, Exporters.find_exporter(export_format).new(klass.user_collection(user), klass.export_serializer).export]
        attachments = klass.download_your_data_images(user)
        export_attachments << [klass.model_name.name.parameterize.pluralize, attachments.flatten] unless attachments.nil?
      end

      [export_data, export_attachments]
    end

    def download_your_data_entities
      @download_your_data_entities ||= DownloadYourDataSerializers.data_entities
    end

    def save_user_data(output, user_data)
      user_data.each do |entity, exporter_data|
        next if exporter_data.read == "\n"

        output.put_next_entry("#{entity}-#{exporter_data.filename}")
        output.write exporter_data.read
      end
    end

    def save_user_attachments(output, user_attachments)
      user_attachments.each do |entity, attachment_block|
        attachment_block.each do |attachment|
          next unless attachment.attached?

          blobs = attachment.is_a?(ActiveStorage::Attached::One) ? [attachment.blob] : attachment.blobs
          blobs.each do |blob|
            blob.open do |blob_file|
              output.put_next_entry("#{entity.parameterize}/#{blob.filename}")
              output.write blob_file.read.force_encoding("UTF-8")
            end
          end
        end
      end
    end
  end
end
