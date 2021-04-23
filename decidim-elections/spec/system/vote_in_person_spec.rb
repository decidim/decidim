# frozen_string_literal: true

require "spec_helper"

describe "Polling Officer zone", type: :system do
  let(:manifest_name) { "elections" }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let!(:election) { create(:election, :complete, component: component) }
  let(:polling_station) { create(:polling_station, voting: voting) }
  let!(:polling_officer) { create(:polling_officer, voting: voting, user: user, presided_polling_station: polling_station) }
  let!(:datum) { create(:datum, full_name: "Jon Doe", document_type: "DNI", document_number: "12345678X", birthdate: Date.civil(1980, 5, 11)) }

  include_context "with a component" do
    let(:voting) { create(:voting, :published, organization: organization) }
    let(:participatory_space) { voting }
    let(:organization_traits) { [:secure_context] }
  end

  before do
    switch_to_secure_context_host
    login_as user, scope: :user

    visit decidim.account_path

    expect(page).to have_content("Polling Officer zone")

    click_link "Polling Officer zone"
    click_link "Identify a person"
  end

  it "can identify a person" do
    expect(page).to have_content("Identify and verify a participant")

    within ".card__content" do
      select("DNI", from: "Document type")
      fill_in "Document number", with: "12345678X"
      fill_in "Day", with: "11"
      fill_in "Month", with: "5"
      fill_in "Year", with: "1980"
      click_button "Validate document"
    end

    expect(page).to have_content("This participant is listed in the census.")
    expect(page).to have_content("Jon Doe")
    click_button "Verify document"

    expect(page).to have_content("The participant has not voted yet.")
    expect(page).to have_content("She is entitled to vote in the following questions:")
    election.questions.each do |question|
      expect(page).to have_content(translated(question.title))
      click_link translated(question.title)
      question.answers.each do |answer|
        expect(page).to have_content(translated(answer.title))
      end
    end

    within ".card__content" do
      check "The participant has voted"
    end
    click_button "Complete voting"

    expect(page).to have_content("In person vote casted successfully")
    expect(page).to have_content("Identify and verify a participant")
  end

  context "when the person data is not valid" do
    it "returns a not found message" do
      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Day", with: "1"
        fill_in "Month", with: "5"
        fill_in "Year", with: "1980"
        click_button "Validate document"
      end

      expect(page).to have_content("This participant is not listed in the census.")
    end
  end
end
