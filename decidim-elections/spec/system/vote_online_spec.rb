# frozen_string_literal: true

require "spec_helper"

describe "Vote online in an election", type: :system do
  let(:manifest_name) { "elections" }
  let!(:election) { create :election, :bb_test, :vote, component: component }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:elections) { create_list(:election, 2, :vote, component: component) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_elections }

  before do
    election.reload # forces to reload the questions in the right order
    login_as user, scope: :user
  end

  include_context "with a component" do
    let(:organization_traits) { [:secure_context] }
  end

  describe "voting with the current user" do
    include_context "with test bulletin board"

    it "can vote and then change the vote", :slow do
      visit_component
      click_link translated(election.title)
      click_link "Start voting"

      expect(page).not_to have_content("This is a preview of the voting booth.")

      uses_the_voting_booth

      page.find("a.focus__exit").click

      expect(page).to have_current_path router.election_path(id: election.id)

      expect(page).to have_content("You have already voted in this election.")
      click_link "Change your vote"

      uses_the_voting_booth
    end
  end

  context "when the election is not published" do
    let(:election) { create :election, :upcoming, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allows admins to preview the voting booth"
  end

  context "when the election has not started yet" do
    let(:election) { create :election, :upcoming, :published, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allows admins to preview the voting booth"
  end

  context "when the election has finished" do
    let(:election) { create :election, :finished, :published, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "doesn't allow admins to preview the voting booth"
  end

  context "when the component requires permissions to vote" do
    before do
      permissions = {
        vote: {
          authorization_handlers: {
            "dummy_authorization_handler" => { "options" => {} }
          }
        }
      }

      component.update!(permissions: permissions)
    end

    it "shows a modal dialog" do
      visit_component

      click_link translated(election.title)
      click_link "Start voting"

      expect(page).to have_content("Authorization required")
    end

    context "when the election has not started yet" do
      let(:election) { create :election, :upcoming, :published, :complete, component: component }

      it_behaves_like "allows admins to preview the voting booth"
    end
  end

  context "when the election requires permissions to vote" do
    before do
      permissions = {
        vote: {
          authorization_handlers: {
            "dummy_authorization_handler" => { "options" => {} }
          }
        }
      }

      election.create_resource_permission(permissions: permissions)
    end

    it "shows a modal dialog" do
      visit_component

      click_link translated(election.title)
      click_link "Start voting"

      expect(page).to have_content("Authorization required")
    end

    context "when the election has not started yet" do
      let(:election) { create :election, :upcoming, :published, :complete, component: component }

      it_behaves_like "allows admins to preview the voting booth"
    end
  end

  context "when the ballot was not send" do
    it "is alerted when trying to leave the component before completing" do
      visit_component

      click_link translated(election.title)
      click_link "Start voting"

      dismiss_prompt do
        page.find("a.focus__exit").click
      end

      expect(page).to have_content("Next")
    end
  end
end
