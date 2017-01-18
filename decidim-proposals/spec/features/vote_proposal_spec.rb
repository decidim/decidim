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
    it "should be given the option to sign in" do
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

    context "when the proposal is not voted yet" do
      it "should be able to vote the proposal" do
        visit decidim_proposals.proposals_path(feature_id: feature, participatory_process_id: participatory_process)

        within ".card__support", match: :first do
          page.find('.card__button').click

          expect(page).to have_css('.card__button.success', text: "Already voted")
          expect(page).to have_content("1 VOTE")
        end
      end
    end

    context "when the proposal is already voted" do
      it "should not be able to vote it again" do
        create(:proposal_vote, proposal: proposals.first, author: user)

        visit decidim_proposals.proposals_path(feature_id: feature, participatory_process_id: participatory_process)

        within "#proposal-#{proposals.first.id}-vote-button" do
          expect(page).to have_css('.card__button.success', text: "Already voted")
          
          page.find('.card__button').click
        end

        within "#proposal-#{proposals.first.id}-votes-count" do
          expect(page).to have_content("1 VOTE")          
        end
      end
    end
  end
end
