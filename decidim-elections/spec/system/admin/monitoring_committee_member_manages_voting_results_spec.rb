# frozen_string_literal: true

require "spec_helper"

describe "Monitoring committee member manages voting results", type: :system do
  include_context "when monitoring committee member manages voting"

  let(:elections_component) { create(:elections_component, participatory_space: voting) }
  let!(:election) { create(:election, :bb_test, :tally_ended, component: elections_component, number_of_votes: 10) }
  let!(:ps_closure) { create_list(:ps_closure, 4, :with_results, election:, number_of_votes: 5) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
  end

  context "when there are more than one finished elections" do
    let!(:other_election) { create(:election, :complete, :published, :finished, component: elections_component) }

    it "lists all the finished elections for the voting" do
      click_link "Validate Results"

      expect(page).to have_content(translated(other_election.title))
      click_link translated(election.title)

      expect(page).to have_content("Results for the election #{translated(election.title)}")
    end
  end

  describe "results verification and publishing", :slow do
    include_context "with test bulletin board"

    it "shows the results for the election" do
      click_link "Validate Results"

      expect(page).to have_content("Results for the election #{translated(election.title)}")

      within ".question_" do
        expect(page).to have_content("Total ballots")
        expect(page).to have_content("20")
        expect(page).to have_content("10")
        expect(page).to have_content("30")
      end

      election.questions.each do |question|
        within ".question_#{question.id}" do
          expect(page).to have_content(translated(question.title))

          question.answers.each do |answer|
            within ".answer_#{answer.id}" do
              expect(page).to have_content(translated(answer.title))
              expect(page).to have_content(answer.results_total)
            end
          end
        end
      end

      click_button "Publish results"

      expect(page).to have_content("Publishing results...")
      expect(page).to have_content("The results were successfully published")
    end
  end
end
