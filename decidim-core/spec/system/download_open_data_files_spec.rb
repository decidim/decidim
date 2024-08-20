# frozen_string_literal: true

require "spec_helper"

describe "Download Open Data files" do
  let(:organization) { create(:organization) }

  context "when downloading open data", download: true do
    before do
      Decidim::OpenDataJob.perform_now(organization)
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "lets the users download open data files" do
      click_on "Download Open Data files"
      expect(File.basename(download_path)).to include("open-data.zip")
      Zip::File.open(download_path) do |zipfile|
        expect(zipfile.glob("*open-data-proposals.csv").length).to eq(1)
        expect(zipfile.glob("*open-data-results.csv").length).to eq(1)
        expect(zipfile.glob("*open-data-meetings.csv").length).to eq(1)
      end
    end
  end
end
