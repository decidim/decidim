# frozen_string_literal: true

require "spec_helper"

describe "Report Proposal", type: :system do
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:proposals) { create_list(:proposal, 3, component:) }
  let(:reportable) { proposals.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let!(:user) { create :user, :confirmed, organization: }

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

      expect(page).to have_selector(".author-data__extra")

      within ".author-data__extra", match: :first do
        page.find("button").click
      end

      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        click_button "Report"
      end

      expect(page).to have_content "report has been created"
    end
  end

  include_examples "reports"
end
