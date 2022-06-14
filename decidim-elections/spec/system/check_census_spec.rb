# frozen_string_literal: true

require "spec_helper"

describe "Check Census", type: :system do
  include Rack::Test::Methods

  let!(:organization) { create(:organization) }
  let!(:voting) { create(:voting, :published, organization: organization, census_contact_information: "census_help@example.com") }
  let!(:dataset) { create(:dataset, :data_created, voting: voting) }
  let!(:datum) do
    create(:datum, document_type: "DNI", document_number: "12345678X", birthdate: Date.civil(1980, 5, 11), postal_code: "04001", dataset: dataset, mobile_phone_number: mobile_phone_number, email: email)
  end
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:mobile_phone_number) { "123456789" }
  let(:email) { "foo@example.com" }
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
      expect(page).to have_content("Can I vote?")
    end
  end

  context "when census data is correct" do
    before do
      visit decidim_votings.voting_check_census_path(voting)
      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Postal code", with: "04001"
        fill_in "Day", with: "11"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1980"
        find("*[type=submit]").click
      end
    end

    it "shows note that census data is correct" do
      within ".wrapper" do
        expect(page).to have_content("Your census data is correct")
        expect(page).not_to have_content("Fill the following form to check your census data:")
      end
    end

    it "shows instructions to ask for access code again, mentioning email and SMS" do
      within ".wrapper" do
        expect(page).to have_content("You should have received your Access Code by postal mail already. In case, you don't have it, you can request it here via SMS or email")
      end
    end
  end

  context "when census data is correct but there is no SMS gateway configured" do
    before do
      Decidim.sms_gateway_service = "FooBar"

      visit decidim_votings.voting_check_census_path(voting)
      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Postal code", with: "04001"
        fill_in "Day", with: "11"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1980"
        find("*[type=submit]").click
      end
    end

    after do
      Decidim.sms_gateway_service = "Decidim::Verifications::Sms::ExampleGateway"
    end

    it "shows instructions to ask for access code again, mentioning only email" do
      within ".wrapper" do
        expect(page).to have_content("You should have received your Access Code by postal mail already. In case, you don't have it, you can request it here via email")
      end
    end
  end

  describe "when asking for access code" do
    before do
      visit decidim_votings.voting_check_census_path(voting)
      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Postal code", with: "04001"
        fill_in "Day", with: "11"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1980"
        find("*[type=submit]").click
      end
    end

    context "when asking by email" do
      it "sends email" do
        click_button "via SMS or email"

        expect(page).to have_content("Get Access Code")

        click_button "Send by email to ****@example.com"

        callout = find(:xpath, '//*[@id="content"]/div[1]')

        expect(callout).to have_content("successfully")
      end
    end

    context "when asking by sms" do
      it "sends sms" do
        click_button "via SMS or email"

        expect(page).to have_content("Get Access Code")

        click_button "Send by SMS"

        callout = find(:xpath, '//*[@id="content"]/div[1]')

        expect(callout).to have_content("successfully")
      end
    end

    context "when datum has no mobile phone number" do
      let(:mobile_phone_number) { nil }

      it "cannot receive access code by SMS" do
        click_button "via SMS or email"

        expect(page).to have_content("Get Access Code")

        expect(page).to have_button("No phone number available")
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

    it "shows note that census data is not correct" do
      within ".wrapper" do
        expect(page).to have_content("The data you have entered are not in the census for this vote")
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
