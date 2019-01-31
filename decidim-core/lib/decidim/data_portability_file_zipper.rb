# frozen_string_literal: true

require "zip"

module Decidim
  # This class performs a task: Creating a Zip file of all DataPortability classes. Originally
  # meant for DataPortability functionality and adding user images to this file, but other usage can be found.
  class DataPortabilityFileZipper < Decidim::DataPortabilityFileReader
    # Public: Initializes the zipper with a user, data, and images to
    # be zipped.
    #
    # user     - The user of data portability to be zipped.
    # data     - An array of all data to be zipped.
    # images   - An array of image files to be inclueded in the zipped file.
    def initialize(user, data, images, token = nil)
      super(user, token)
      @export_data = data
      @export_images = images
    end

    # Public: Zips the file.
    #
    # Returns a String with the zipped version of the file.
    def make_zip
      Zip::OutputStream.open(file_path) do |zos|
        @export_data.each do |element|
          filename_file = element.last.filename(element.first.parameterize)

          zos.put_next_entry(filename_file)
          if element.last.read.presence
            zos.write element.last.read
          else
            zos.write "No data"
          end
        end
      end

      zipfile = Zip::File.open(file_path)
      @export_images.each do |image_block|
        next if image_block.last.nil?
        image_block.last.each do |image|
          next if image.file.nil?
          folder_name = image_block.first.parameterize
          uploader = Decidim::ApplicationUploader.new(image.model, image.mounted_as)
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
          zipfile.add("#{folder_name}/#{image.file.filename}", my_image_path)
          CarrierWave.clean_cached_files!
        end
      end
      zipfile.close
    end
  end
end
