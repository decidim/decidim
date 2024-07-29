# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Census
      describe AccessCodesExporter do
        subject { AccessCodesExporter.new(dataset, tmp_file_in, password) }

        let(:tmp_file_in) do
          Dir::Tmpname.create(["access_codes", ".7z"]) do
            # just get an empty file name
          end
        end
        let(:tmp_dir_out) { Dir.mktmpdir("access_codes_exporter_spec") }
        let(:dataset) { create(:dataset, :with_access_code_data) }
        let(:password) { "secret" }
        let(:user) { create(:user) }
        let(:expected_file) { "#{translated(dataset.voting.title).parameterize}-voting-access-codes.csv" }

        describe "#export" do
          it "compresses a password protected file" do
            subject.export

            open_7z_and_extract_zip(tmp_file_in)

            data = File.read(File.join(tmp_dir_out, expected_file))
            files = Dir.children(tmp_dir_out)
            expect(files).to contain_exactly(expected_file)

            dataset.data.each do |datum|
              expect(data).to include(datum.full_name)
              expect(data).to include(datum.full_address)
              expect(data).to include(datum.postal_code)
              expect(data).to include(datum.access_code)
            end
          end
        end

        private

        def open_7z_and_extract_zip(file_path)
          SevenZipWrapper.extract_and_decrypt(filename: file_path, password:, output_directory: tmp_dir_out)
        end
      end
    end
  end
end
