# frozen_string_literal: true

require "spec_helper"

describe "Report Proposal" do
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:proposals) { create_list(:proposal, 3, :participant_author, component:) }
  let(:reportable) { proposals.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let(:reportable_index_path) { resource_locator(reportable).index }

  let!(:component) do
    create(:proposal_component,
           manifest:,
           participatory_space: participatory_process)
  end

  context "when the author is a meeting" do
    let!(:proposal) { create(:proposal, :official_meeting, component:) }
    let(:reportable) { proposal }
    let(:reportable_path) { resource_locator(reportable).path }

    before do
      login_as user, scope: :user
    end

    it "reports the resource" do
      visit reportable_path

      expect(page).to have_css(%(button[data-dialog-open="flagModal"]))
      find(%(button[data-dialog-open="flagModal"])).click
      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        click_button "Report"
      end

      expect(page).to have_content "report has been created"
    end

    context "when reporting user is platform admin" do
      let!(:user) { create(:user, :admin, :confirmed, organization:) }

      include_examples "higher user role reports"
      include_examples "higher user role does not have hide"
    end

    context "when reporting user is process admin" do
      let!(:user) { create(:process_admin, :confirmed, participatory_process:) }

      include_examples "higher user role reports"
      include_examples "higher user role does not have hide"
    end

    context "when reporting user is process collaborator" do
      let!(:user) { create(:process_collaborator, :confirmed, participatory_process:) }

      include_examples "higher user role reports"
      include_examples "higher user role does not have hide"
    end

    context "when reporting user is process moderator" do
      let!(:user) { create(:process_moderator, :confirmed, participatory_process:) }

      include_examples "higher user role reports"
      include_examples "higher user role does not have hide"
    end

    context "when reporting user is process valuator" do
      let!(:user) { create(:process_valuator, :confirmed, participatory_process:) }

      include_examples "higher user role reports"
      include_examples "higher user role does not have hide"
    end
  end

  include_examples "reports by user type"
end
