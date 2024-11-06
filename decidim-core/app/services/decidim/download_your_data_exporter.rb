# frozen_string_literal: true

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
    # export_format - The format of the data files inside the zip file. (CSV by default)
    def initialize(user, path, export_format = DEFAULT_EXPORT_FORMAT)
      @user = user
      @path = File.expand_path path
      @export_format = export_format
    end

    def export
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.binwrite(path, data)
    end

    private

    attr_reader :user, :export_format, :path

    def data
      user_data, user_attachments = data_and_attachments_for_user
      buffer = Zip::OutputStream.write_buffer do |out|
        save_user_data(out, user_data)
        save_user_attachments(out, user_attachments)
      end

      buffer.string
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
