# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_open_data_shared_context"
require "decidim/core/test/shared_examples/download_open_data_shared_examples"

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
      let(:resource_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it_behaves_like "does not include it in the open data ZIP file"
    end

    context "when the participatory process is published and open" do
      let!(:participatory_process) { create(:participatory_process, :published, :open, organization:) }
      let(:resource_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the participatory process is published and transparent" do
      let!(:participatory_process) { create(:participatory_process, :published, :transparent, organization:) }
      let(:resource_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the participatory process is published and restricted" do
      let!(:participatory_process) { create(:participatory_process, :published, :restricted, organization:) }
      let(:resource_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

      it_behaves_like "does not include it in the open data ZIP file"
    end
  end

  describe "open data page" do
    let(:resource_type) { "participatory_processes" }
    let!(:participatory_process) { create(:participatory_process, :published, organization:) }
    let(:resource_title) { translated_attribute(participatory_process.title).gsub('"', '""') }

    it_behaves_like "includes it in the open data CSV file"
  end
end
