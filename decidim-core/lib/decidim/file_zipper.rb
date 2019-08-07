# frozen_string_literal: true

require "zip"

module Decidim
  # This class performs a simple task: Zipping a single file. Originally
  # meant for mailers to attach files, but other usage can be found.
  class FileZipper
    # Public: Initializes the zipper with a filename and the data to
    # be zipped.
    #
    # filename - The file name of the file *inside* the zip.
    # data     - A string with the data to be zipped.
    def initialize(filename, data)
      @data = data
      @filename = filename
    end

    # Public: Zips the file.
    #
    # Returns a String with the zipped version of the file.
    def zip
      @zip ||= Zip::OutputStream.write_buffer do |zipfile|
        zipfile.put_next_entry(@filename)
        zipfile.write @data
      end.string
    end
  end
end
