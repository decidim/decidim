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
    expect(page).to have_content("These files are in CSV (Comma-Separated Values) format, which is a widely-used file format")

    click_on("How to open and work with these files")
    expect(page).to have_content("1. Download the files")

    click_on("Detailed explanation of each file")
    expect(page).to have_content("Below is a description of each dataset, including its schema (structure) and the type of information it contains")
    expect(page).to have_content("The component that the result belongs to")

    expect(page).to have_content("Components")

    %w(results result_comments projects debates debate_comments meetings meeting_comments proposals proposal_comments).each do |section|
      expect(page).to have_content(section)
    end

    expect(page).to have_content("Participatory spaces")
    %w(participatory_processes assemblies conferences initiatives).each do |section|
      expect(page).to have_content(section)
    end

    expect(page).to have_content("Core")
    %w(moderated_users moderations users user_groups).each do |section|
      expect(page).to have_content(section)
    end

    I18n.t("decidim.open_data.help").each do |section|
      next if %w(core).include?(section.first.to_s)

      section.last.each do |dict|
        expect(page).to have_content(I18n.t("decidim.open_data.help.#{section.first}.#{dict.first}"))
      end
    end

    click_on("License")
    expect(page).to have_content("Open Database License")
  end
end
