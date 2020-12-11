# frozen_string_literal: true

require "spec_helper"

describe "Vote in an election", type: :system do
  let(:manifest_name) { "elections" }
  let(:election) { create :election, :complete, :published, :ongoing, component: component }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:elections) do
    create_list(:election, 2, :complete, :published, :ongoing, component: component)
  end

  before do
    election.reload
    login_as user, scope: :user
    allow(Decidim::Elections.bulletin_board).to receive(:cast_vote).and_return({ ok: true })
  end

  include_context "with a component with secure context"

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

  context "when the election did not started yet" do
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
      click_link "Vote"

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
      click_link "Vote"

      expect(page).to have_content("Authorization required")
    end

    it_behaves_like "allow admins to preview the voting booth"
  end

  context "when the voting is confirmed" do
    before do
      visit_component

      click_link translated(election.title)
      click_link "Vote"
    end

    it_behaves_like "uses the voting booth"
  end

  context "when the voting is not confirmed" do
    it "is alerted when trying to leave the component before completing" do
      visit_component

      click_link translated(election.title)
      click_link "Vote"

      dismiss_prompt do
        page.find("a.focus__exit").click
      end

      expect(page).to have_content("Next")
    end
  end
end
