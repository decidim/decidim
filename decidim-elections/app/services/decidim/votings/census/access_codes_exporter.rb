# frozen_string_literal: true

require "seven_zip_ruby"
require "zip"

module Decidim
  module Votings
    module Census
      # Public: Generates a 7z(seven zip) file with data files ready to be persisted
      # somewhere so users can download their data.
      #
      # The 7z file wraps a ZIP file which finally contains the data files.
      class AccessCodesExporter
        include TranslatableAttributes

        FILE_NAME_PATTERN = "%{voting_name}-voting-access-codes.csv"

        attr_reader :dataset, :path, :password

        # Public: Initializes the class.
        #
        # dataset       - The Voting::Census::Dataset to export the access codes for.
        # path          - The String path where to write the zip file.
        # password      - The password to protect the zip file.
        def initialize(dataset, path, password)
          @dataset = dataset
          @path = File.expand_path path
          @password = password
        end

        def export
          dirname = File.dirname(@path)
          FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
          File.open(@path, "wb") do |file|
            SevenZipRuby::Writer.open(file, password:) do |szw|
              szw.header_encryption = true
              szw.add_data(csv_data.read, format(FILE_NAME_PATTERN, voting_name: translated_attribute(dataset.voting.title).parameterize))
            end
          end
        end

        private

        def csv_data
          Decidim::Exporters::CSV.new(dataset.data, Decidim::Votings::Census::DatumSerializer).export
        end
      end
    end
  end
end
