# frozen_string_literal: true

require "spec_helper"

describe "Transparent Space Proposal" do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:member) { create(:member, user: other_user, participatory_space:) }

  let!(:participatory_space) { create(:assembly, :published, :transparent, organization:) }
  let!(:component) { create(:proposal_component, participatory_space:) }

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { creation_enabled: true })
  end

  def visit_component
    page.visit main_component_path(component)
  end

  context "when the user is not logged in" do
    it "allows creating a proposal" do
      visit_component

      within "aside" do
        expect(page).to have_no_link("New proposal")
      end
    end

    context "when the component has votes enabled and the proposal has votes" do
      let!(:proposal) { create(:proposal, :official, :with_votes, component:) }

      before do
        component.default_step_settings = component.default_step_settings.to_h.merge({ votes_enabled: true })
        component.save!
      end

      context "when accessing the proposal page" do
        let(:target_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

        before do
          visit target_path
        end

        it "can access the page and see the votes" do
          expect(page).to have_text(proposal.title["en"])
          expect(page).to have_text("Votes")
        end
      end

      context "when accessing the proposal list page" do
        before do
          visit_component
        end

        it "can see the votes" do
          expect(page).to have_text("Votes")
        end
      end
    end
  end

  context "when the user is logged in" do
    context "and is member space" do
      before do
        login_as other_user, scope: :user
      end

      it "allows creating a proposal" do
        visit_component

        within "aside" do
          expect(page).to have_link("New proposal")
        end
      end
    end

    context "and is not member space" do
      before do
        login_as user, scope: :user
      end

      it "does not allow creating a proposal" do
        visit_component

        within "aside" do
          expect(page).to have_no_link("New proposal")
        end
      end
    end
  end
end
