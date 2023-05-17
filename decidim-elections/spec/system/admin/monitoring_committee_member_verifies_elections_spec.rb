# frozen_string_literal: true

require "spec_helper"

describe "Monitoring committee member verifies elections", type: :system do
  include_context "when monitoring committee member manages voting"

  let(:elections_component) { create(:elections_component, participatory_space: voting) }
  let!(:election) { create(:election, :tally_ended, :published, component: elections_component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
  end

  context "when the user has not accepted the admin TOS" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "shows a message to accept the admin TOS" do
      expect(page).to have_content("Please take a moment to review the admin terms of service")
    end
  end

  context "when listing the elections" do
    it "lists all the polling stations for the voting" do
      click_link "Verify Elections"

      within "#monitoring_committee_verify_elections table" do
        expect(page).to have_content(translated(election.title))
        expect(page).to have_link("Download", href: election.verifiable_results_file_url)
        expect(page).to have_content(election.verifiable_results_file_hash)
      end
    end
  end
end
