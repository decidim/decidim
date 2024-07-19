# frozen_string_literal: true

require "spec_helper"
require "decidim/seven_zip_wrapper"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, tmp_file_in, password) }

    let(:tmp_file_in) {  Dir::Tmpname.create(["download-your-data", ".7z"]) {} }
    let(:tmp_dir_out) { Dir.mktmpdir("download_your_data_exporter_spec") }
    let(:password) { "download-your-data.7z>passwd" }
    let(:user) { create(:user) }

    describe "#export" do
      it "compresses a password protected file" do
        expect(File.exist?(tmp_file_in)).to be false

        # generate 7z
        subject.export

        expect(File.exist?(tmp_file_in)).to be true

        open_7z_and_extract_zip(tmp_file_in)

        expect(Dir.entries(tmp_dir_out).count).to eq 3
      end
    end

    private

    def open_7z_and_extract_zip(file_path)
      SevenZipWrapper.extract_and_decrypt(filename: file_path, password:, output_directory: tmp_dir_out)
    end
  end
end
