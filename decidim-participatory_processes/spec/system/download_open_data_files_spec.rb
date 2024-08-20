# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_open_data_shared_context"

describe "Download Open Data files", download: true do
  let(:organization) { create(:organization) }

  include_context "when downloading open data files"

  it "lets the users download open data files" do
    download_open_data_file

    expect(File.basename(download_path)).to include("open-data.zip")
    Zip::File.open(download_path) do |zipfile|
      expect(zipfile.glob("*open-data-participatory_processes.csv").length).to eq(1)
    end
  end

  describe "participatory processes" do
    let(:file_name) { "open-data-participatory_processes.csv" }

    context "when there is none" do
      it "returns an empty file" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).to eq("\n")
      end
    end

    context "when the participatory process is unpublished" do
      let!(:participatory_process) { create(:participatory_process, :unpublished, organization:) }
      let(:participatory_process_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it "does not include it" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).not_to include(participatory_process_title)
      end
    end

    context "when the participatory process is published and not private" do
      let!(:participatory_process) { create(:participatory_process, :published, organization:, private_space: false) }
      let(:participatory_process_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it "includes it" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).to include(participatory_process_title)
      end
    end

    context "when the participatory process is published and private" do
      let!(:participatory_process) { create(:participatory_process, :published, organization:, private_space: true) }
      let(:participatory_process_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it "does not include it" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).not_to include(participatory_process_title)
      end
    end
  end
end
