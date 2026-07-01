# frozen_string_literal: true

require "spec_helper"

describe "Private Space Proposal" do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }

  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: other_user, privatable_to: participatory_space_private) }

  let!(:participatory_space) { participatory_space_private }

  let!(:component) { create(:proposal_component, participatory_space:) }

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { creation_enabled: true })
  end

  def visit_component
    page.visit main_component_path(component)
  end

  context "when space is private and transparent" do
    let!(:participatory_space_private) { create(:assembly, :published, organization:, private_space: true, is_transparent: true) }

    context "when the user is not logged in" do
      it "does not allow create a proposal" do
        visit_component

        within "aside" do
          expect(page).to have_no_link("New proposal")
        end
      end
    end

    context "when the user is logged in" do
      context "and is private user space" do
        before do
          login_as other_user, scope: :user
        end

        it "not allows create a proposal" do
          visit_component

          within "aside" do
            expect(page).to have_link("New proposal")
          end
        end
      end

      context "and is not private user space" do
        before do
          login_as user, scope: :user
        end

        it "not allows create a proposal" do
          visit_component

          within "aside" do
            expect(page).to have_no_link("New proposal")
          end
        end
      end
    end
  end

  context "when the spaces is private and not transparent" do
    let!(:participatory_space_private) { create(:assembly, :published, organization:, private_space: true, is_transparent: false) }

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
      context "and is private user space" do
        before do
          login_as other_user, scope: :user
        end

        it "allows create a proposal" do
          visit_component

          click_on "New proposal"

          within ".new_proposal" do
            fill_in :proposal_title, with: "Creating my proposal"
            fill_in :proposal_body, with: "This is my proposal's body and I am using it unwisely."

            find("*[type=submit]").click
          end

          expect(page).to have_content("Publish your proposal")
        end
      end

      context "and is not private user space" do
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
end
