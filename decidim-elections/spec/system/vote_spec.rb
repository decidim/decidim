# frozen_string_literal: true

require "spec_helper"

describe "Vote in an election", type: :system do
  let(:manifest_name) { "elections" }
  let(:election) { create :election, :bb_test, :vote, component: component }
  let(:user) { create(:user, :confirmed, created_at: Date.civil(2020, 1, 1), organization: component.organization) }
  let!(:elections) do
    create_list(:election, 2, :vote, component: component)
  end

  let(:message_id) { vote.message_id }
  let(:vote_id) { vote.id }

  before do
    election.reload
    login_as user, scope: :user
  end

  include_context "with a component" do
    let(:organization_traits) { [:secure_context] }
  end

  it_behaves_like "allows to vote"

  shared_examples "allow admins to preview the voting booth" do
    let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

    it_behaves_like "allows to preview booth"
  end

  context "when the election is not published" do
    let(:election) { create :election, :ongoing, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allow admins to preview the voting booth"
  end

  context "when the election has not started yet" do
    let(:election) { create :election, :upcoming, :published, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allow admins to preview the voting booth"
  end

  context "when the election has finished" do
    let(:election) { create :election, :finished, :published, :complete, component: component }

    it_behaves_like "doesn't allow to vote"
    it_behaves_like "allow admins to preview the voting booth"
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

    it_behaves_like "allow admins to preview the voting booth"
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

    it_behaves_like "allow admins to preview the voting booth"
  end

  context "when the voting is not confirmed" do
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

  context "when the voter has already casted a vote" do
    let!(:vote) { create :vote, election: election, user: user, status: "accepted" }

    it_behaves_like "allows to change the vote"
  end
end
