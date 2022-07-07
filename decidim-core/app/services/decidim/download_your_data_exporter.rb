# frozen_string_literal: true

require "seven_zip_ruby"
require "zip"
require_relative "zip_stream/writer"

module Decidim
  # Public: Generates a 7z(seven zip) file with data files ready to be persisted
  # somewhere so users can download their data.
  #
  # In fact, the 7z file wraps a ZIP file which finally contains the data files.
  class DownloadYourDataExporter
    include ::Decidim::ZipStream::Writer

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
      dirname = File.dirname(@path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.open(@path, "wb") do |file|
        SevenZipRuby::Writer.open(file, password: @password) do |szw|
          szw.header_encryption = true
          szw.add_data(data, ZIP_FILE_NAME)
        end
      end
    end

    private

    def data
      buffer = Zip::OutputStream.write_buffer do |out|
        user_data, attachments = data_for(@user, @export_format)

        add_user_data_to_zip_stream(out, user_data)
        add_attachments_to_zip_stream(out, attachments)
      end

      buffer.string
    end

    def data_for(user, format)
      export_data = []
      export_attachments = []

      download_your_data_entities.each do |object|
        klass = Object.const_get(object)
        export_data << [klass.model_name.name.parameterize.pluralize, Exporters.find_exporter(format).new(klass.user_collection(user), klass.export_serializer).export]
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
