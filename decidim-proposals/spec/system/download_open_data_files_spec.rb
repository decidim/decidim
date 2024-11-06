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
      expect(zipfile.glob("*open-data-proposals.csv").length).to eq(1)
    end
  end

  describe "proposals" do
    let(:file_name) { "open-data-proposals.csv" }

    context "when there is none" do
      it "returns an empty file" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).to eq("\n")
      end
    end

    context "when the proposal's component is unpublished" do
      let!(:proposal) { create(:proposal, component:) }
      let(:resource_title) { translated_attribute(proposal.title).gsub('"', '""') }
      let(:component) { create(:proposal_component, :unpublished, organization:) }

      it_behaves_like "does not include it in the open data ZIP file"
    end

    context "when the proposal's component is published" do
      let!(:proposal) { create(:proposal, component:) }
      let(:resource_title) { translated_attribute(proposal.title).gsub('"', '""') }
      let(:component) { create(:proposal_component, organization:) }

      it_behaves_like "includes it in the open data ZIP file"
    end
  end

  describe "open data page" do
    let(:resource_type) { "proposals" }
    let!(:proposal) { create(:proposal, component:) }
    let(:component) { create(:proposal_component, organization:) }
    let(:resource_title) { translated_attribute(proposal.title).gsub('"', '""') }

    it_behaves_like "includes it in the open data CSV file"
  end
end
