# frozen_string_literal: true
require "spec_helper"

describe "Vote Proposal", type: :feature do
  let(:feature) { create(:proposal_feature) }
  let(:organization) { feature.organization }
  let(:participatory_process) { feature.participatory_process }
  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when the user is not logged in" do
    it "when the vote proposal button is clicked the sign in popup is shown" do
      visit decidim_proposals.proposals_path(feature_id: feature, participatory_process_id: participatory_process)

      within ".card__support", match: :first do
        page.find('.card__button').click
      end

      expect(page).to have_css('#loginModal', visible: true)
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end
  end
end
