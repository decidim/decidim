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
        user_data, export_images = data_for(@user, @export_format)

        add_user_data_to_zip_stream(out, user_data)
        add_images_to_zip_stream(out, export_images)
      end

      buffer.string
    end

    def data_for(user, format)
      export_data = []
      export_images = []

      data_portability_entities.each do |object|
        klass = Object.const_get(object)
        export_data << [klass.model_name.name.parameterize.pluralize, Exporters.find_exporter(format).new(klass.user_collection(user), klass.export_serializer).export]
        export_images << [klass.model_name.name.parameterize.pluralize, klass.data_portability_images(user).flatten] unless klass.data_portability_images(user).nil?
      end

      [export_data, export_images]
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

    def add_images_to_zip_stream(out, export_images)
      export_images.each do |image_block|
        next if image_block.last.nil?

        folder_name = image_block.first.parameterize
        image_block.last.each do |image|
          next if image.file.nil?

          uploader = ApplicationUploader.new(image.model, image.mounted_as)
          if image.file.respond_to? :file
            uploader.cache!(File.open(image.file.file))
            uploader.retrieve_from_store!(image.file.filename)
          else
            my_uploader = element.send(image.mounted_as)

            my_uploader.cache_stored_file!
            my_uploader.retrieve_from_cache!(my_uploader.cache_name)
          end
          my_image_path = image.file.file
          next unless File.exist?(my_image_path)

          out.put_next_entry("#{folder_name}/#{image.file.filename}")
          File.open(image.file.file) do |f|
            out << f.read
          end
          CarrierWave.clean_cached_files!
        end
      end
    end
  end
end
