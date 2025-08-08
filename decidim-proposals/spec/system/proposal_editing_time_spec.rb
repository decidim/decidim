# frozen_string_literal: true

require "spec_helper"

describe "editing a proposal" do
  include_context "with a component"
  let!(:author) { create(:user, :confirmed, organization: component.organization) }
  let(:manifest_name) { "proposals" }
  let!(:scope) { create(:scope, organization:) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:proposal) { create(:proposal, component:, users: [author]) }
  let(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           organization:,
           participatory_space: participatory_process,
           settings: {
             edit_time:,
             proposal_edit_time: "limited"
           })
  end

  before do
    freeze_time
    login_as(author, scope: :user)
    travel_to(proposal.updated_at + check_time)
    visit_component
    click_on(translated(proposal.title))
  end

  context "when the edit time is within the limit" do
    let!(:edit_time) { [10, "minutes"] }
    let(:check_time) { 6.minutes }

    it "shows the edit button" do
      find("#dropdown-trigger-resource-#{proposal.id}").click
      expect(page).to have_link("Edit")
    end
  end

  context "when the edit time has passed" do
    let(:edit_time) { [11, "minutes"] }
    let(:check_time) { 12.minutes }

    it "does not show the edit button" do
      find("#dropdown-trigger-resource-#{proposal.id}").click
      expect(page).to have_no_link("Edit")
    end
  end

  context "when the edit time is set to hours" do
    let(:edit_time) { [1, "hours"] }
    let(:check_time) { 30.minutes }

    it "shows the edit button" do
      find("#dropdown-trigger-resource-#{proposal.id}").click
      expect(page).to have_link("Edit")
    end

    context "and the time has passed" do
      let(:check_time) { 2.hours }

      it "does not show the edit button" do
        find("#dropdown-trigger-resource-#{proposal.id}").click
        expect(page).to have_no_link("Edit")
      end
    end
  end

  context "when the edit time is set to days" do
    let(:edit_time) { [1, "days"] }
    let(:check_time) { 12.hours }

    it "shows the edit button" do
      find("#dropdown-trigger-resource-#{proposal.id}").click
      expect(page).to have_link("Edit")
    end

    context "and the time has passed" do
      let(:check_time) { 2.days }

      it "does not show the edit button" do
        find("#dropdown-trigger-resource-#{proposal.id}").click
        expect(page).to have_no_link("Edit")
      end
    end
  end
end
