# frozen_string_literal: true

require "spec_helper"

describe "Amend Proposal", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let!(:user) { create :user, :confirmed, organization: organization }

  context "when amendments are not enabled" do
    it "doesn't show the amend proposal button" do
      visit_component

      click_link proposal.title
      expect(page).to have_no_button("Amend Proposal")
    end
  end

  context "when amendments are enabled" do
    let!(:component) do
      create(:proposal_component,
             :with_amendments_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    context "when the user is not logged in" do
      it "is given the option to sign in" do
        visit_component
        click_link proposal.title

        within ".card__amend-button", match: :first do
          click_button "Amend Proposal"
        end

        expect(page).to have_css("#loginModal", visible: true)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end
    end
  end
end
