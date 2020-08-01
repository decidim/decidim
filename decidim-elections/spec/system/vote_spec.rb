# frozen_string_literal: true

require "spec_helper"

describe "Vote in an election", type: :system do
  let(:manifest_name) { "elections" }
  let(:election) { create :election, :complete, :published, :ongoing, component: component }
  let(:user) { create(:user, :confirmed, organization: component.organization) }

  before do
    election.reload
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  include_context "with a component"

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
end
