# frozen_string_literal: true

require "spec_helper"

describe "Action Authorization" do
  include_context "with a component"

  let(:manifest_name) { "proposals" }

  let!(:organization) do
    create(:organization, available_authorizations:)
  end
  let(:available_authorizations) { [] }

  let!(:proposal) { create(:proposal, component:) }

  let!(:component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest:,
      participatory_space:,
      permissions:
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when using a handler authorization", with_authorization_workflows: ["dummy_authorization_handler"] do
    let(:available_authorizations) { ["dummy_authorization_handler"] }

    context "and action authorized" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_handler: {} } } }
      end

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to authorization" do
        expect(page).to have_content("We need to verify your identity")
        expect(page).to have_css("h1", text: "Verify with Example authorization")
      end
    end

    context "and action authorized with custom action authorizer options" do
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567"
                }
              }
            }
          }
        }
      end

      it "redirects to authorization" do
        visit main_component_path(component)
        click_on "New proposal"
        expect(page).to have_content("We need to verify your identity")

        expect(page).to have_css("h1", text: "Verify with Example authorization")
        expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
      end

      context "when the user does not match one of the authorization criteria" do
        let(:postal_code) { "1234" }
        let!(:user_authorization) do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.second.ago,
                                 metadata: { postal_code: })
        end

        before do
          visit main_component_path(component)
        end

        context "when the code is incorrect" do
          let(:postal_code) { "aaaa" }

          it "prompts user to check their authorization status" do
            visit main_component_path(component)
            click_on "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
          end
        end

        context "when the postal code is missing" do
          let(:postal_code) { "" }

          it "prompts user to check their authorization status" do
            click_on "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
            expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
          end
        end
      end

      context "when the authorization is incomplete" do
        let(:permissions) do
          {
            create: {
              authorization_handlers: {
                dummy_authorization_handler: {
                  options: {
                    allowed_postal_codes: "1234, 4567",
                    extra_param: "wadus"
                  }
                }
              }
            }
          }
        end

        let!(:user_authorization) do
          create(
            :authorization,
            name: "dummy_authorization_handler",
            user:,
            granted_at: 1.second.ago
          )
        end

        it "redirects to authorization to complete the pending data" do
          visit main_component_path(component)

          click_on "New proposal"

          expect(page).to have_content("Your verification has not been completed with all the necessary information")
          expect(page).to have_css("h1", text: "Verify with Example authorization")
        end
      end
    end

    context "and action authorized and authorization expired" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_handler: {} } } }
      end

      before do
        create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.month.ago)
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to resume authorization when modal clicked" do
        expect(page).to have_content("Your authorization has expired")
        expect(page).to have_content("Verify with Example authorization")
      end
    end

    context "when action not authorized" do
      let(:permissions) { nil }

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "goes directly to action" do
        expect(page).to have_css("h1", text: "Create new proposal")
      end
    end
  end

  context "when using two handler authorizations", with_authorization_workflows: %w(dummy_authorization_handler another_dummy_authorization_handler) do
    let(:available_authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }

    context "and action authorized" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_handler: {}, another_dummy_authorization_handler: {} } } }
      end

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to onboarding pending" do
        expect(page).to have_content("You are almost ready to create a proposal")
        expect(page).to have_css("a[data-verification]", count: 2)
      end
    end

    context "and action authorized with custom action authorizer options" do
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567"
                }
              },
              another_dummy_authorization_handler: {}
            }
          }
        }
      end

      it "redirects to authorization when selected on onboarding page" do
        visit main_component_path(component)
        click_on "New proposal"
        expect(page).to have_content("You are almost ready to create a proposal")

        click_on "Example authorization"

        expect(page).to have_css("h1", text: "Verify with Example authorization")
        expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
      end

      context "when the user does not match one of the authorization criteria" do
        let(:postal_code) { "1234" }
        let!(:user_authorization) do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.second.ago,
                                 metadata: { postal_code: })
        end

        before do
          visit main_component_path(component)
        end

        context "when incorrect code" do
          let(:postal_code) { "aaaa" }

          it "prompts user to check their authorization status" do
            visit main_component_path(component)
            click_on "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
          end
        end

        context "when the postal code is missing" do
          let(:postal_code) { "" }

          it "prompts user to check their authorization status" do
            click_on "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
            expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
          end
        end
      end
    end

    context "and action authorized and authorization expired" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_handler: {}, another_dummy_authorization_handler: {} } } }
      end

      before do
        create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.month.ago)
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to resume authorization when selected on onboarding page" do
        expect(page).to have_content("You are almost ready to create a proposal")

        page.find("div.verification", text: "Example authorization").click
        click_on "Continue"

        expect(page).to have_content("Verify with Example authorization")
      end
    end

    context "when action not authorized" do
      let(:permissions) { nil }

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "goes directly to action" do
        expect(page).to have_css("h1", text: "Create new proposal")
      end
    end
  end

  context "when using a workflow authorization", with_authorization_workflows: ["dummy_authorization_workflow"] do
    let(:available_authorizations) { ["dummy_authorization_workflow"] }

    context "and action authorized" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_workflow: {} } } }
      end

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to authorization" do
        expect(page).to have_content("DUMMY VERIFICATION")
      end
    end

    context "and action authorized and authorization already started" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_workflow: {} } } }
      end

      before do
        create(:authorization, :pending, name: "dummy_authorization_workflow", user:)
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to resume authorization" do
        expect(page).to have_content("CONTINUE YOUR VERIFICATION")
      end
    end

    context "and action authorized and authorization expired" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_workflow: {} } } }
      end

      before do
        create(:authorization, name: "dummy_authorization_workflow", user:, granted_at: 1.month.ago)
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "redirects to resume authorization" do
        expect(page).to have_content("DUMMY VERIFICATION ENGINE")
      end
    end

    context "when action not authorized" do
      let(:permissions) { nil }

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      it "goes directly to action" do
        expect(page).to have_css("h1", text: "Create new proposal")
      end
    end
  end
end
