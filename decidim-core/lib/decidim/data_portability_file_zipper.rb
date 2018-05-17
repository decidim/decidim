# frozen_string_literal: true

require "zip"

module Decidim
  class DataPortabilityFileZipper < Decidim::DataPortabilityFileReader

    def initialize(user, data, token=nil)
      super(user, token)
      @export_data = data
    end

    def make_zip
      filedownload = Zip::OutputStream.open(file_path) do |zos|
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
    end
  end
end
