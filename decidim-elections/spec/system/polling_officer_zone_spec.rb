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

    describe "creates a closure" do
      it "can add results for the polling station" do
        visit decidim_votings_polling_officer_zone.new_polling_officer_election_closure_path(assigned_polling_officer, election)
        expect(page).to have_content("Vote recount")
        within ".form.new_closure" do
          fill_in "envelopes_result_total_ballots_count", with: 0
          find("#envelopes_result_total_ballots_count").native.send_keys(:tab)
          find("*[type=submit]").click
        end

        expect(page).to have_content("Closure successfully created")
      end
    end

    describe "when adding results to the closure" do
      before do
        visit decidim_votings_polling_officer_zone.new_polling_officer_election_closure_path(assigned_polling_officer, election)
        within ".form.new_closure" do
          fill_in "envelopes_result_total_ballots_count", with: 0
          find("#envelopes_result_total_ballots_count").native.send_keys(:tab)
          find("*[type=submit]").click
        end
      end

      it "can add results for the polling station" do
        expect(page).to have_content("Vote recount - Answers recount")

        within ".form.edit_closure" do
          fill_in "closure_result__ballot_results__valid_ballots_count", with: 0
          fill_in "closure_result__ballot_results__blank_ballots_count", with: 0
          fill_in "closure_result__ballot_results__null_ballots_count", with: 0
          find("#closure_result__ballot_results__null_ballots_count").native.send_keys(:tab)

          questions.each do |question|
            question.answers.each do |answer|
              fill_in "closure_result__answer_results__#{answer.id}_value", with: Faker::Number.number(digits: 1)
            end
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("Closure results successfully updated")
      end
    end
  end
end
