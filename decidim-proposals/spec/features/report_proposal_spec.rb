# frozen_string_literal: true
require "spec_helper"

describe "Report Proposal", type: :feature do
  include_context "feature"
  let(:manifest_name) { "proposals" }
  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let(:proposal) { proposals.first }
  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:feature) do
    create(:proposal_feature,
      manifest: manifest,
      participatory_process: participatory_process)
  end

  context "when the user is not logged in" do
    it "should be given the option to sign in" do
      visit_feature
      click_link proposal.title

      within ".author-data__extra", match: :first do
        page.find('button').click
      end

      expect(page).to have_css('#loginModal', visible: true)
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "and the user has not reported the proposal yet" do
      it "reports the proposal" do
        visit_feature
        click_link proposal.title

        within ".author-data__extra", match: :first do
          page.find('button').click
        end

        expect(page).to have_css('#flagModal', visible: true)

        choose "proposal_report_type_offensive"

        within "#flagModal" do
          click_button "Report"
        end

        expect(page).to have_content "has been reported"
      end
    end

    context "and the user has reported the proposal previously" do
      before do
        create(:proposal_report, proposal: proposal, user: user, type: "spam")
      end

      it "cannot report it twice" do
        visit_feature
        click_link proposal.title

        within ".author-data__extra", match: :first do
          page.find('button').click
        end

        expect(page).to have_css('#flagModal', visible: true)

        expect(page).to have_content "already reported"        
      end
    end
  end
end
