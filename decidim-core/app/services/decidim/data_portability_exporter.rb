# frozen_string_literal: true

require "seven_zip_ruby"

module Decidim
  # Public: It generates a ZIP file with Open Data CSV files ready
  # to be uploaded somewhere so users can download an organization
  # data.
  class DataPortabilityExporter
    # Public: Initializes the class.
    #
    # organization - The Organization to export the data from.
    # path         - The String path where to write the zip file.
    def initialize(user, path, format, password)
      @user = user
      @path = File.expand_path path
      @format = format
      @password = password
    end

    def export
      dirname = File.dirname(@path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.open(@path, "wb") do |file|
        SevenZipRuby::Writer.open(file, password: @password) do |szw|
          szw.add_data(data, "#{SecureRandom.urlsafe_base64}.7z")
        end
      end
    end

    private

    def data
      buffer = Zip::OutputStream.write_buffer do |out|
        export_data, export_images = data_for(@user, @format)

        export_data.each do |element|
          filename_file = element.last.filename(element.first.parameterize)

          out.put_next_entry(filename_file)
          if element.last.read.presence
            out.write element.last.read
          else
            out.write "No data"
          end
        end

        export_images.each do |image_block|
          next if image_block.last.nil?

          image_block.last.each do |image|
            next if image.file.nil?

            folder_name = image_block.first.parameterize
            uploader = ApplicationUploader.new(image.model, image.mounted_as)
            if image.file.respond_to? :file
              uploader.cache!(File.open(image.file.file))
              uploader.retrieve_from_store!(image.file.filename)
            else
              my_uploader = image.mounted_as
              element = image.model

              element.send(my_uploader).cache_stored_file!
              element.send(my_uploader).retrieve_from_cache!(element.send(my_uploader).cache_name)
            end
            my_image_path = File.open(image.file.file)
            next unless File.exist?(my_image_path)

            out.add("#{folder_name}/#{image.file.filename}", my_image_path)
            CarrierWave.clean_cached_files!
          end
        end
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
  end
end
