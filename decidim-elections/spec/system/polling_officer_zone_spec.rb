# frozen_string_literal: true

require "spec_helper"

describe "Polling Officer zone", type: :system do
  let(:organization) { create(:organization, :secure_context) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:polling_officers) { [assigned_polling_officer, unassigned_polling_officer] }
  let(:voting) { create(:voting, organization: organization) }
  let(:other_voting) { create(:voting, organization: organization) }
  let(:polling_station) { create(:polling_station, voting: voting) }
  let(:assigned_polling_officer) { create(:polling_officer, voting: voting, user: user, presided_polling_station: polling_station) }
  let(:unassigned_polling_officer) { create(:polling_officer, voting: other_voting, user: user) }

  before do
    polling_officers
    switch_to_secure_context_host
    login_as user, scope: :user
  end

  it "can access to the polling officer zone" do
    visit decidim.account_path

    expect(page).to have_content("Polling Officer zone")

    click_link "Polling Officer zone"

    expect(page).to have_content("You are not assigned to any Polling Station yet.")
  end

  context "when the user is not a polling officer" do
    let(:polling_officers) { [create(:polling_officer)] }

    it "can't access to the polling officer zone" do
      visit decidim.account_path

      expect(page).not_to have_content("Polling Officer zone")

      visit decidim.decidim_votings_polling_officer_zone_path

      expect(page).to have_content("You are not authorized to perform this action")

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when the user is a polling officer and an election has finished" do
    let(:component) { create(:elections_component, participatory_space: voting) }
    let!(:election) { create(:election, :finished, questions: questions, component: component) }
    let(:questions) { [create(:question, :complete)] }

    it "can access the new results form for the polling station" do
      visit decidim.decidim_votings_polling_officer_zone_path

      within ".card__polling_station" do
        expect(page).to have_content(translated(election.title))
        expect(page).to have_content("Count votes")
      end
    end

    it "can add results for the polling station" do
      visit decidim_votings_polling_officer_zone.new_polling_officer_result_path(assigned_polling_officer, election)

      expect(page).to have_content("Vote recount - Answers recount")

      within ".form.new_result" do
        questions.each do |question|
          question.answers.each do |answer|
            fill_in "election_result__answer_results__#{answer.id}_votes_count", with: Faker::Number.number(digits: 1)
          end
        end
        find("*[type=submit]").click
      end

      expect(page).to have_content("Results successfully created")
    end
  end
end
