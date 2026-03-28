# frozen_string_literal: true

require "spec_helper"

describe "Restricted Space Proposal" do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:member) { create(:member, user: other_user, participatory_space:) }

  let!(:participatory_space) { create(:assembly, :published, :restricted, organization:) }
  let!(:component) { create(:proposal_component, participatory_space:) }

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { creation_enabled: true })
  end

  context "when the user is not logged in" do
    let(:target_path) { main_component_path(component) }

    before do
      visit target_path
    end

    it "disallows the access" do
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end

  context "when the user is logged in" do
    context "and is member space" do
      before do
        login_as other_user, scope: :user
      end

      it "allows create a proposal" do
        page.visit main_component_path(component)

        click_on "New proposal"

        within ".new_proposal" do
          fill_in :proposal_title, with: "Creating my proposal"
          fill_in :proposal_body, with: "This is my proposal's body and I am using it unwisely."

          find("*[type=submit]").click
        end

        expect(page).to have_content("Publish your proposal")
      end
    end

    context "and is not member space" do
      let(:target_path) { main_component_path(component) }

      before do
        login_as user, scope: :user
        visit target_path
      end

      it "disallows the access" do
        expect(page).to have_content("You are not authorized to perform this action")
      end
    end

    context "and is an admin" do
      let!(:user) { create(:user, :admin, :confirmed, organization:) }

      context "when the component has votes enabled and the proposal has votes" do
        let!(:proposal) { create(:proposal, :official, :with_votes, component:) }

        before do
          component.default_step_settings = component.default_step_settings.to_h.merge({ votes_enabled: true })
          component.save!
        end

        context "when accessing the component page" do
          let(:target_path) { main_component_path(component) }

          before do
            login_as user, scope: :user
            visit target_path
          end

          it "displays the proposals votes count" do
            expect(page).to have_content("Votes")
          end
        end

        context "when accessing the proposal page" do
          let(:target_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

          before do
            login_as user, scope: :user
            visit target_path
          end

          it "displays the proposals votes count" do
            expect(page).to have_content("Votes")
          end
        end
      end
    end
  end
end
