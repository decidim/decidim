# frozen_string_literal: true

require "seven_zip_ruby"

module Decidim
  # Public: Generates a 7z(seven zip) file with data files ready to be persisted
  # somewhere so users can download their data.
  #
  # In fact, the 7z file wraps a ZIP file which finally contains the data files.
  class DataPortabilityExporter
    DEFAULT_EXPORT_FORMAT = "CSV"
    ZIP_FILE_NAME = "data-portability.zip"

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

      data_portability_entities.each do |object|
        klass = Object.const_get(object)
        export_data << [klass.model_name.name.parameterize.pluralize, Exporters.find_exporter(format).new(klass.user_collection(user), klass.export_serializer).export]
        attachments = klass.data_portability_images(user)
        export_attachments << [klass.model_name.name.parameterize.pluralize, attachments.flatten] unless attachments.nil?
      end

      [export_data, export_attachments]
    end

    def data_portability_entities
      @data_portability_entities ||= DataPortabilitySerializers.data_entities
    end

    def add_user_data_to_zip_stream(out, user_data)
      user_data.each do |element|
        filename_file = element.last.filename(element.first.parameterize)

        out.put_next_entry(filename_file)
        if element.last.read.presence
          out.write element.last.read
        else
          out.write "No data"
        end
      end
    end

    def add_attachments_to_zip_stream(out, export_attachments)
      export_attachments.each do |attachment_block|
        next if attachment_block.last.nil?

        folder_name = attachment_block.first.parameterize
        attachment_block.last.each do |attachment_uploader|
          next if attachment_uploader.file.nil?

          case attachment_uploader.fog_provider
          when "fog" # file system
            next unless File.exist?(attachment_uploader.file.file)
          when "fog/aws"
            cache_attachment_from_aws(attachment_uploader)
          else
            Rails.logger.info "Carrierwave fog_provider not supported by DataPortabilityExporter for attachment: #{attachment_uploader.attributes}"
            next
          end

          attachment_local_path= attachment_uploader.file.file
          out.put_next_entry("#{folder_name}/#{attachment_uploader.file.filename}")
          File.open(attachment_local_path) do |f|
            out << f.read
          end
          CarrierWave.clean_cached_files!
        end
      end
    end

    # Retrieves the file from AWS and stores it into a temporal cache.
    # Once the file is cached, the uploader returns a local `CarrierWave::SanitizedFile`
    # instead of a fog file that acts as a proxy to the remote file.
    def cache_attachment_from_aws(uploader)
      uploader.cache_stored_file!
      uploader.retrieve_from_cache!(uploader.cache_name)
    end

  end
end
