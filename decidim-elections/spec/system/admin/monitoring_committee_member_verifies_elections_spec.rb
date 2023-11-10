# frozen_string_literal: true

require "spec_helper"

describe "Monitoring committee member verifies elections" do
  include_context "when monitoring committee member manages voting"

  let(:elections_component) { create(:elections_component, participatory_space: voting) }
  let!(:election) { create(:election, :tally_ended, :published, component: elections_component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
  end

  it_behaves_like "needs admin TOS accepted" do
    let(:user) { create(:user, :confirmed, organization:) }
  end

  context "when listing the elections" do
    it "lists all the polling stations for the voting" do
      within_admin_sidebar_menu do
        click_link "Verify Elections"
      end

      within "#monitoring_committee_verify_elections table" do
        expect(page).to have_content(translated(election.title))
        expect(page).to have_link("Download", href: election.verifiable_results_file_url)
        expect(page).to have_content(election.verifiable_results_file_hash)
      end
    end
  end
end
