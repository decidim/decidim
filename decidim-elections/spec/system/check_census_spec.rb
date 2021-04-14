# frozen_string_literal: true

require "spec_helper"

describe "Check Census", type: :system do
  include Rack::Test::Methods

  let!(:organization) { create(:organization) }
  let!(:voting) { create(:voting, :published, organization: organization, census_contact_information: "census_help@example.com") }
  let!(:dataset) { create(:dataset, :data_created, voting: voting) }
  let!(:datum) do
    create(:datum, document_type: "DNI", document_number: "12345678X", birthdate: Date.civil(1980, 5, 11), postal_code: "04001", dataset: dataset)
  end
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
    switch_to_host(organization.host)
  end

  after do
    Rack::Attack.reset!
  end

  context "when requesting the check census path" do
    before do
      visit decidim_votings.voting_check_census_path(voting)
    end

    it "shows the title of the page" do
      expect(page).to have_content("Check your census data")
    end
  end

  context "when census data is correct" do
    before do
      visit decidim_votings.voting_check_census_path(voting)
    end

    it "shows note that census data is correct" do
      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Postal code", with: "04001"
        fill_in "Day", with: "11"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1980"
        find("*[type=submit]").click
      end

      within ".wrapper" do
        expect(page).to have_content("Your census data is correct")
        expect(page).not_to have_content("Fill the following form to check your census data:")
      end
    end
  end

  context "when no census data is found" do
    before do
      visit decidim_votings.voting_check_census_path(voting)
      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "987654321X"
        fill_in "Postal code", with: "04004"
        fill_in "Day", with: "01"
        fill_in "Month", with: "12"
        fill_in "Year", with: "1982"
        find("*[type=submit]").click
      end
    end

    it "shows note that census data is correct" do
      within ".wrapper" do
        expect(page).to have_content("Your census data is incorrect")
        expect(page).to have_content("Fill the following form to check your census data:")
      end
    end

    it "shows contact information to edit census data if wrong" do
      within ".wrapper" do
        expect(page).to have_content("census_help@example.com")
      end
    end
  end

  context "when post request gets attacked" do
    before do
      visit decidim_votings.voting_check_census_path(voting)
      6.times do
        within ".card__content" do
          select("DNI", from: "Document type")
          fill_in "Document number", with: "987654321X"
          fill_in "Postal code", with: "04004"
          fill_in "Day", with: "01"
          fill_in "Month", with: "12"
          fill_in "Year", with: "1982"
          find("*[type=submit]").click
        end
      end
    end

    it "throttles after 5 attempts per minute" do
      expect(page).to have_content("Retry later")
    end
  end
end
