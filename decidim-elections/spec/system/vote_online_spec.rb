# frozen_string_literal: true

require "spec_helper"

describe "Vote online in an election", type: :system do
  let(:manifest_name) { "elections" }
  let!(:election) { create :election, :bb_test, :vote, component: }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:elections) { create_list(:election, 2, :vote, component:) } # prevents redirect to single election page
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

    context "when there's description in a question" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Elections::Answer.update_all(description: { en: "Some text" })
        # rubocop:enable Rails/SkipsModelValidations
      end

      it "shows a link to view more information about the election" do
        visit_component
        click_link translated(election.title)
        click_link "Start voting"
        expect(page).to have_content("MORE INFORMATION")
      end
    end

    context "when there's no description in a question" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Elections::Answer.update_all(description: {})
        # rubocop:enable Rails/SkipsModelValidations
      end

      it "does not show the more information link" do
        visit_component
        click_link translated(election.title)
        click_link "Start voting"
        expect(page).not_to have_content("MORE INFORMATION")
      end
    end
  end

  context "when the election is not published" do
    let(:election) { create :election, :upcoming, :complete, component: }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allows admins to preview the voting booth"
  end

  context "when the election has not started yet" do
    let(:election) { create :election, :upcoming, :published, :complete, component: }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allows admins to preview the voting booth"
  end

  context "when the election has finished" do
    let(:election) { create :election, :finished, :published, :complete, component: }

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

      component.update!(permissions:)
    end

    it "shows a modal dialog" do
      visit_component

      click_link translated(election.title)
      click_link "Start voting"

      expect(page).to have_content("Authorization required")
    end

    context "when the election has not started yet" do
      let(:election) { create :election, :upcoming, :published, :complete, component: }

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

      election.create_resource_permission(permissions:)
    end

    it "shows a modal dialog" do
      visit_component

      click_link translated(election.title)
      click_link "Start voting"

      expect(page).to have_content("Authorization required")
    end

    context "when the election has not started yet" do
      let(:election) { create :election, :upcoming, :published, :complete, component: }

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

  context "when the comunication with bulletin board fails" do
    before do
      election.questions.last.destroy!
      election.questions.last.destroy!
      election.questions.last.destroy!
      allow(Decidim::Elections.bulletin_board).to receive(:bulletin_board_server).and_return("http://idontexist.tld/api")
    end

    it "alerts the user about the error" do
      visit_component
      click_link translated(election.title)
      click_link "Start voting"

      within "#server-failure" do
        expect(page).to have_content("Something went wrong")
      end
    end
  end
end
