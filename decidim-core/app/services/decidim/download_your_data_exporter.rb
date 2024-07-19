# frozen_string_literal: true

require "decidim/seven_zip_wrapper"

module Decidim
  # Public: Generates a 7z(seven zip) file with data files ready to be persisted
  # somewhere so users can download their data.
  #
  # In fact, the 7z file wraps a ZIP file which finally contains the data files.
  class DownloadYourDataExporter
    DEFAULT_EXPORT_FORMAT = "CSV"
    ZIP_FILE_NAME = "download-your-data.zip"

    # Public: Initializes the class.
    #
    # user          - The user to export the data from.
    # path          - The String path where to write the zip file.
    # password      - The password to protect the zip file.
    # export_format - The format of the data files inside the zip file. (CSV by default)
    def initialize(user, path, password, export_format = DEFAULT_EXPORT_FORMAT)
      @user = user
      @path = File.expand_path path
      @export_format = export_format
      @password = password
    end

    def export
      tmpdir = Dir.mktmpdir("temporary-download-your-data-dir")
      user_data, attachments = data_for_user

      user_data.each do |entity, exporter_data|
        next if exporter_data.read == "\n"

        file_name = File.join(tmpdir, "#{entity}-#{exporter_data.filename}")
        File.write(file_name, exporter_data.read)
      end

      attachments.each do |entity, attachment_block|
        attachment_block.each do |attachment|
          next unless attachment.attached?

          blobs = attachment.is_a?(ActiveStorage::Attached::One) ? [attachment.blob] : attachment.blobs
          blobs.each do |blob|
            Dir.mkdir(File.join(tmpdir, entity.parameterize))
            file_name = File.join(tmpdir, entity.parameterize, blob.filename.to_s)
            blob.open do |blob_file|
              File.write(file_name, blob_file.read.force_encoding("UTF-8"))
            end
          end
        end
      end

      SevenZipWrapper.compress_and_encrypt(filename: @path, password: @password, input_directory: tmpdir)
    end

    private

    attr_reader :user, :export_format

    def data_for_user
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
  end
end
