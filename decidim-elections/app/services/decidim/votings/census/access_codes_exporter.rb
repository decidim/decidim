# frozen_string_literal: true

require "decidim/seven_zip_wrapper"

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
          tmpdir = Dir.mktmpdir("votings-access-code-exporter")
          save_voting_access_code_data(tmpdir)
          SevenZipWrapper.compress_and_encrypt(filename: @path, password: @password, input_directory: tmpdir)
        end

        private

        def save_voting_access_code_data(tmpdir)
          file_name = File.join(
            tmpdir,
            format(FILE_NAME_PATTERN, voting_name: translated_attribute(dataset.voting.title).parameterize)
          )
          File.write(file_name, csv_data.read)
        end

        def csv_data
          Decidim::Exporters::CSV.new(dataset.data, Decidim::Votings::Census::DatumSerializer).export
        end
      end
    end
  end
end
