# frozen_string_literal: true

require "spec_helper"

shared_context "with resources to be endorsed or not" do
  include_context "with a component"

  # Should be overriden and create one main resource
  let!(:resource) { nil }
  # the name of the resource to be clicked from the component view
  let(:resource_name) { nil }
  # Should be overriden and create 3 extra resources in the current component
  let!(:resources) { nil }
end

shared_examples "Endorse resource system specs" do
  def expect_page_not_to_include_endorsements
    expect(page).to have_no_button("Like")
    expect(page).to have_no_css("#resource-#{resource.id}-endorsements-count")
  end

  def expect_endorsements_count(count)
    return if Decidim.redesign_active

    within "#resource-#{resource.id}-endorsements-count" do
      expect(page).to have_content(count.to_s)
    end
  end

  def visit_resource
    visit_component
    click_link resource_name
  end

  context "when endorsements are not enabled" do
    let(:component_traits) { [:with_votes_enabled, :with_endorsements_disabled] }

    context "when the user is not logged in" do
      it "does not show the endorse resource button and counts" do
        visit_resource
        expect_page_not_to_include_endorsements
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "does not show the endorse resource button and counts" do
        visit_resource
        expect_page_not_to_include_endorsements
      end
    end
  end

  context "when endorsements are enabled but blocked" do
    let(:component_traits) { [:with_endorsements_enabled, :with_endorsements_blocked] }
    let(:disabled_button_selector) { Decidim.redesign_active ? "a.button[disabled='true']" : ".buttons__row span[disabled]" }

    it "shows the endorsements count and the endorse button is disabled" do
      visit_resource
      expect(page).to have_css(disabled_button_selector)
    end
  end

  context "when endorsements are enabled" do
    let(:component_traits) { [:with_votes_enabled, :with_endorsements_enabled] }

    context "when the user is not logged in" do
      it "is given the option to sign in" do
        visit_resource
        within ".buttons__row", match: :first do
          click_button "Like"
        end

        expect(page).to have_css("#loginModal", visible: :visible)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "when the resource is not endorsed yet" do
        it "is able to endorse the resource" do
          visit_resource
          within ".buttons__row" do
            click_button "Like"
            expect(page).to have_button("Dislike")
          end

          expect_endorsements_count(1)
        end
      end

      context "when the resource is already endorsed" do
        let!(:endorsement) { create(:endorsement, resource:, author: user) }

        it "is not able to endorse it again" do
          visit_resource
          within ".buttons__row" do
            expect(page).to have_button("Dislike")
            expect(page).to have_no_button("Like")
          end

          expect_endorsements_count(1)
        end

        it "is able to undo the endorsement" do
          visit_resource
          within ".buttons__row" do
            click_button "Dislike"
            expect(page).to have_button("Like")
          end

          expect_endorsements_count(0)
        end
      end

      context "when verification is required" do
        let(:permissions) do
          {
            endorse: {
              authorization_handlers: {
                "dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        end

        before do
          organization.available_authorizations = ["dummy_authorization_handler"]
          organization.save!
          component.update(permissions:)
        end

        context "when user is NOT verified" do
          it "is NOT able to endorse" do
            visit_resource
            within ".buttons__row", match: :first do
              click_button "Like"
            end
            expect(page).to have_css("#authorizationModal", visible: :visible)
          end
        end

        context "when user IS verified" do
          before do
            handler_params = { user: }
            handler_name = "dummy_authorization_handler"
            handler = Decidim::AuthorizationHandler.handler_for(handler_name, handler_params)

            Decidim::Authorization.create_or_update_from(handler)
          end

          it "IS able to endorse", :slow do
            visit_resource
            within ".buttons__row", match: :first do
              click_button "Like"
            end
            expect(page).to have_button("Dislike")
          end
        end
      end
    end
  end
end
