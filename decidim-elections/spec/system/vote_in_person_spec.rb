# frozen_string_literal: true

require "spec_helper"

describe "Polling Officer zone", type: :system do
  let(:manifest_name) { "elections" }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:election) { create(:election, :complete, :bb_test, :vote, component:) }
  let(:polling_station) { create(:polling_station, id: 1, voting:) }
  let!(:polling_officer) { create(:polling_officer, voting:, user:, presided_polling_station: polling_station) }
  let!(:datum) { create(:datum, dataset:, full_name: "Jon Doe", document_type: "DNI", document_number: "12345678X", birthdate: Date.civil(1980, 5, 11)) }
  let(:dataset) { create(:dataset, voting:) }

  include_context "with a component" do
    let(:voting) { create(:voting, :published, organization:) }
    let(:participatory_space) { voting }
    let(:organization_traits) { [:secure_context] }
  end

  before do
    switch_to_secure_context_host
    login_as user, scope: :user

    visit decidim.account_path

    expect(page).to have_content("Polling Officer zone")

    click_link "Polling Officer zone"
  end

  shared_examples "a polling officer registers an in person vote" do
    include_context "with test bulletin board"

    let(:questions_title) { "They're entitled to vote in the following questions:" }
    let(:census_verified) { "This participant has not voted in person yet." }

    it "can identify a person and register their vote", :slow do
      click_link "Identify a person"

      fill_person_data

      expect(page).to have_content("This participant is listed in the census.")
      expect(page).to have_content("Jon Doe")
      click_button "Verify document"

      election.reload
      expect(page).to have_content(census_verified)
      expect(page).to have_content(questions_title)
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

      expect(page).to have_content("The vote was registered successfully.")
      expect(page).to have_content("Identify and verify a participant")
    end
  end

  it_behaves_like "a polling officer registers an in person vote"

  context "when the participant already voted online" do
    let!(:vote) { create :vote, election:, voter_id: }
    let(:voter_id) { vote_flow.voter_id }
    let(:vote_flow) do
      ret = Decidim::Votings::CensusVoteFlow.new(election)
      ret.voter_in_person(document_type: "DNI", document_number: "12345678X", day: "11", month: "5", year: "1980")
      ret
    end

    it_behaves_like "a polling officer registers an in person vote" do
      let(:census_verified) { "This participant has already voted online. If they vote in person, the previous votes will be invalidated and this will be the definitive vote." }
      let(:questions_title) { "This participant has already voted online and is entitled to vote in the following questions:" }
    end
  end

  context "when the participant already voted in person" do
    let!(:in_person_vote) { create :in_person_vote, :accepted, election:, polling_officer:, voter_id: }
    let(:voter_id) { vote_flow.voter_id }
    let(:vote_flow) do
      ret = Decidim::Votings::CensusVoteFlow.new(election)
      ret.voter_in_person(document_type: "DNI", document_number: "12345678X", day: "11", month: "5", year: "1980")
      ret
    end

    it "doesn't allow them to vote" do
      click_link "Identify a person"

      fill_person_data

      expect(page).to have_content("This participant is listed in the census.")
      expect(page).to have_content("Jon Doe")
      click_button "Verify document"

      expect(page).to have_content("This participant has already voted in person and is not entitled to vote.")
      expect(page).not_to have_content("Complete voting")
      click_link "Identify another participant"

      expect(page).to have_content("Identify and verify a participant")
    end
  end

  context "when there is a pending in person vote to be registered" do
    let!(:in_person_vote) { create :in_person_vote, election:, polling_officer: }

    it "redirects to the waiting page" do
      click_link "Identify a person"

      expect(page).to have_content("Waiting for the in person vote to be registered")
    end
  end

  context "when the person data is not valid" do
    it "returns a not found message" do
      click_link "Identify a person"

      fill_person_data(correct: false)

      expect(page).to have_content("This participant is not listed in the census.")
    end
  end

  def fill_person_data(correct: true)
    within ".card__content" do
      select("DNI", from: "Document type")
      fill_in "Document number", with: "12345678X"
      fill_in "Day", with: correct ? "11" : "1"
      fill_in "Month", with: "5"
      fill_in "Year", with: "1980"
      click_button "Validate document"
    end
  end
end
