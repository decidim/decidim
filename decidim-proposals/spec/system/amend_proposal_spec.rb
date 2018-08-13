# frozen_string_literal: true

require "spec_helper"

describe "Amend Proposal", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:user_group) { create(:user_group, :verified, organization: organization, users: [user]) }

  context "when amendments are not enabled" do
    it "doesn't show the amend proposal button" do
      visit_component

      click_link proposal.title
      expect(page).to have_no_link("Amend Proposal")
    end
  end

  context "when amendments are enabled" do
    let!(:component) do
      create(:proposal_component,
             :with_amendments_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    context "and visits an amendable proposal" do
      before do
        visit_component
        click_link proposal.title
      end

      it "renders a link to Ammend it" do
        expect(page).to have_link("Amend Proposal")
      end
      context "when the user is not logged in and clicks" do
        it "is shown the login modal" do
          within ".card__amend-button", match: :first do
            click_link "Amend Proposal"
          end

          expect(page).to have_css("#loginModal", visible: true)
        end
      end

      context "when the user is logged in and clicks" do
        before do
          login_as user, scope: :user
          visit_component
          click_link proposal.title
        end

        it "is shown the amend form" do
          within ".card__amend-button", match: :first do
            click_link "Amend Proposal"
          end

          expect(page).to have_css(".edit_amend", visible: true)
          expect(page).to have_content("CREATE YOUR AMENDMENT")
        end
      end

      context "and the amend form shows all the fields" do
        before do
          login_as user, scope: :user
          visit decidim.new_amend_path(amendable_gid: proposal.to_sgid.to_s)
        end

        it "is shown the amend title field" do
          expect(page).to have_css("#amend_title", visible: true)
        end
        it "is shown the amend body field" do
          expect(page).to have_css("#amend_body", visible: true)
        end
        it "is shown the Create amend as field" do
          expect(page).to have_css("#amend_user_group_id", visible: true)
        end
        it "is shown the submit button" do
          expect(page).to have_button("Send emendation")
        end
      end

      context "and the emendation is sent" do
        before do
          login_as user, scope: :user
          visit decidim.new_amend_path(amendable_gid: proposal.to_sgid.to_s)
          within ".edit_amend" do
            fill_in :amend_title, with: "More sidewalks and less roads"
            fill_in :amend_body, with: "Cities need more people, not more cars"
            select user_group.name, from: :amend_user_group_id
          end
          click_button "Send emendation"
        end

        it "is shown the Success Callout" do
          expect(page).to have_css(".callout.success", text: "The amendment has been created successfully")
        end
      end
    end
  end
end
