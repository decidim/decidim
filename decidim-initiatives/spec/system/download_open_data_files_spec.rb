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
      expect(zipfile.glob("*open-data-initiatives.csv").length).to eq(1)
    end
  end

  describe "initiatives" do
    let(:file_name) { "open-data-initiatives.csv" }

    context "when there is none" do
      it "returns an empty file" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).to eq("\n")
      end
    end

    context "when the initiative is in state 'created'" do
      let!(:initiative) { create(:initiative, :created, organization:) }
      let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

      it_behaves_like "does not include it in the open data ZIP file"
    end

    context "when the initiative is in state 'validating'" do
      let!(:initiative) { create(:initiative, :validating, organization:) }
      let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

      it_behaves_like "does not include it in the open data ZIP file"
    end

    context "when the initiative is in state 'open'" do
      let!(:initiative) { create(:initiative, :open, organization:) }
      let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the initiative is in state 'accepted'" do
      let!(:initiative) { create(:initiative, :accepted, organization:) }
      let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the initiative is in state 'rejected'" do
      let!(:initiative) { create(:initiative, :rejected, organization:) }
      let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the initiative is in state 'discarded'" do
      let!(:initiative) { create(:initiative, :discarded, organization:) }
      let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end
  end

  describe "open data page" do
    let(:resource_type) { "initiatives" }
    let!(:initiative) { create(:initiative, :open, organization:) }
    let(:resource_title) { translated_attribute(initiative.title).gsub('"', '""') }

    it_behaves_like "includes it in the open data CSV file"
  end
end
