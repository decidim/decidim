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
      expect(zipfile.glob("*open-data-assemblies.csv").length).to eq(1)
    end
  end

  describe "assemblies" do
    let(:file_name) { "open-data-assemblies.csv" }

    context "when there is none" do
      it "returns an empty file" do
        download_open_data_file
        content = extract_content_from_zip(download_path, file_name)
        expect(content).to eq("\n")
      end
    end

    context "when the assembly is unpublished" do
      let!(:assembly) { create(:assembly, :unpublished, organization:) }
      let(:resource_title) { translated_attribute(assembly.title).gsub('"', '""') }

      it_behaves_like "does not include it in the open data ZIP file"
    end

    context "when the assembly is published and not private" do
      let!(:assembly) { create(:assembly, :published, organization:, private_space: false) }
      let(:resource_title) { translated_attribute(assembly.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the assembly is published, private and transparent" do
      let!(:assembly) { create(:assembly, :published, organization:, private_space: true, is_transparent: true) }
      let(:resource_title) { translated_attribute(assembly.title).gsub('"', '""') }

      it_behaves_like "includes it in the open data ZIP file"
    end

    context "when the assembly is published, private and not transparent" do
      let!(:assembly) { create(:assembly, :published, organization:, private_space: true, is_transparent: false) }
      let(:resource_title) { translated_attribute(assembly.title).gsub('"', '""') }

      it_behaves_like "does not include it in the open data ZIP file"
    end
  end

  describe "open data page" do
    let(:resource_type) { "assemblies" }
    let!(:assembly) { create(:assembly, :published, organization:, private_space: false) }
    let(:resource_title) { translated_attribute(assembly.title).gsub('"', '""') }

    it_behaves_like "includes it in the open data CSV file"
  end
end
