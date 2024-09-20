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
      expect(zipfile.glob("*open-data-meeting_comments.csv").length).to eq(1)
      expect(zipfile.glob("*open-data-meetings.csv").length).to eq(1)
      expect(zipfile.glob("*open-data-projects.csv").length).to eq(1)
      expect(zipfile.glob("*open-data-proposal_comments.csv").length).to eq(1)
      expect(zipfile.glob("*open-data-proposals.csv").length).to eq(1)
      expect(zipfile.glob("*open-data-result_comments.csv").length).to eq(1)
      expect(zipfile.glob("*open-data-results.csv").length).to eq(1)
    end
  end
end
