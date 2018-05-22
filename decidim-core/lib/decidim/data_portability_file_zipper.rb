# frozen_string_literal: true

require "zip"

module Decidim
  class DataPortabilityFileZipper < Decidim::DataPortabilityFileReader
    def initialize(user, data, images, token = nil)
      super(user, token)
      @export_data = data
      @export_images = images
    end

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
          name = image.split("/").last
          folder_name = image_block.first.parameterize
          my_image_path = Rails.root.join("public/#{image.sub!(%r{^/}, "")}")
          next unless File.exist?(my_image_path)
          zipfile.add("#{folder_name}/#{name}", my_image_path)
        end
      end
      zipfile.close
    end
  end
end
