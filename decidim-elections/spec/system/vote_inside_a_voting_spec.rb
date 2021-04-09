# frozen_string_literal: true

require "spec_helper"

describe "Vote in an election inside a Voting", type: :system do
  let(:manifest_name) { "elections" }
  let!(:election) { create :election, :bb_test, :vote, component: component }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:datum) do
    create(:datum, :with_access_code, document_type: "DNI", document_number: "12345678X", birthdate: Date.civil(1980, 5, 11), postal_code: "04001", access_code: "1234")
  end
  let!(:elections) { create_list(:election, 2, :vote, component: component) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_voting_elections }

  include_context "with a component" do
    let(:voting) { create(:voting, :published, organization: organization) }
    let(:participatory_space) { voting }
    let(:organization_traits) { [:secure_context] }
  end

  before do
    election.reload # forces to reload the questions in the right order
    login_as(user, scope: :user) if user
  end

  shared_examples "votes with the census data" do
    include_context "with test bulletin board"

    it "can vote and then change the vote", :slow do
      visit_component
      click_link translated(election.title)
      click_link "Start voting"

      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Postal code", with: "04001"
        fill_in "Day", with: "11"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1980"
        fill_in "Access code", with: "1234"
        find("*[type=submit]").click
      end

      expect(page).not_to have_content("This is a preview of the voting booth.")

      uses_the_voting_booth

      expect(page).not_to have_content("You have already voted in this election.")
      click_link "Start voting"
    end
  end

  it_behaves_like "votes with the census data"

  context "when there is no user logged in" do
    let(:user) { nil }

    it_behaves_like "votes with the census data"
  end

  context "when the voting is not published" do
    let(:election) { create :election, :upcoming, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allows admins to preview the voting booth"
  end

  context "when the census data is not right" do
    it "can't vote", :slow do
      visit_component
      click_link translated(election.title)
      click_link "Start voting"

      within ".card__content" do
        select("DNI", from: "Document type")
        fill_in "Document number", with: "12345678X"
        fill_in "Postal code", with: "04001"
        fill_in "Day", with: "11"
        fill_in "Month", with: "05"
        fill_in "Year", with: "1980"
        fill_in "Access code", with: "1235"
        find("*[type=submit]").click
      end

      expect(page).to have_content("Document number")
      expect(page).to have_content("The given data doesn't match any voter.")
    end
  end
end
