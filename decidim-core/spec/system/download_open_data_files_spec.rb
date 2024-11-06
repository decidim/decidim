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

  it "shows the page with the download links" do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_on "Open Data"

    expect(page).to have_content("Here, you will find data files that are regularly generated from various deliberative and governance processes within")
    expect(page).to have_content("Download results in CSV format")

    click_on("Detailed explanation of each file")
    expect(page).to have_content("Below is a description of each dataset, including its schema (structure) and the type of information it contains")
    expect(page).to have_content("The component that the result belongs to")

    click_on("License")
    expect(page).to have_content("Open Database License")
  end
end
