# frozen_string_literal: true

require "spec_helper"

describe "Action Authorization", type: :system do
  include_context "with a component"

  let(:manifest_name) { "proposals" }

  let!(:organization) do
    create(:organization, available_authorizations: [authorization])
  end

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
    let(:authorization) { "dummy_authorization_handler" }

    context "and action authorized" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_handler: {} } } }
      end

      before do
        visit main_component_path(component)
        click_link "New proposal"
      end

      it "prompts user to authorize" do
        expect(page).to have_content("Authorization required")
        expect(page).to have_content("In order to perform this action, you need to be authorized with \"Example authorization\"")
      end

      it "prompts the user to authorize again after modal reopening" do
        click_button "×"
        click_link "New proposal"

        expect(page).to have_content("Authorization required")
        expect(page).to have_content("In order to perform this action, you need to be authorized with \"Example authorization\"")
      end

      it "redirects to authorization when modal clicked" do
        click_link "Authorize with \"Example authorization\""

        expect(page).to have_selector("h1", text: "Verify with Example authorization")
      end
    end

    context "and action authorized with custom action authorizer options" do
      let(:scope) { create :scope, organization: }
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567",
                  allowed_scope_id: scope.id
                }
              }
            }
          }
        }
      end

      before do
        visit main_component_path(component)
      end

      it "prompts user to authorize" do
        click_link "New proposal"

        expect(page).to have_content("Authorization required")
        expect(page).to have_content("In order to perform this action, you need to be authorized with \"Example authorization\"")
        expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
        expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}.")
      end

      it "redirects to authorization when modal clicked" do
        click_link "New proposal"
        click_link "Authorize with \"Example authorization\""

        expect(page).to have_selector("h1", text: "Verify with Example authorization")
        expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
        expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}.")
      end

      context "when the user doesn't match the authorization criteria" do
        let(:other_scope) { create :scope, organization: }
        let!(:user_authorization) do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.second.ago,
                                 metadata: { postal_code: "1234", scope_id: other_scope.id })
        end

        it "prompts user to check their authorization status" do
          click_link "New proposal"

          expect(page).to have_content("Not authorized")
          expect(page).to have_content("Sorry, you can't perform this action as some of your authorization data doesn't match.")
          expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}, and your scope is #{other_scope.name["en"]}.")
        end
      end

      context "when the user doesn't match one of the authorization criteria" do
        let(:user_scope) { create :scope, organization: }
        let(:postal_code) { "1234" }
        let!(:user_authorization) do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.second.ago,
                                 metadata: { postal_code:, scope_id: user_scope&.id })
        end

        context "when the postal code is missing" do
          let(:postal_code) { "" }

          it "prompts user to check their authorization status" do
            click_link "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you can't perform this action as some of your authorization data doesn't match.")
            expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
            expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}, and your scope is #{user_scope.name["en"]}.")
          end
        end

        context "when the scope is missing" do
          let(:user_scope) { nil }

          it "prompts user to check their authorization status" do
            click_link "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you can't perform this action as some of your authorization data doesn't match.")
            expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}.")
          end
        end

        context "when the scope and postal code is missing" do
          let(:user_scope) { nil }
          let(:postal_code) { nil }

          it "prompts user to check their authorization status" do
            click_link "New proposal"

            expect(page).to have_content("Not authorized")
            expect(page).to have_content("Sorry, you can't perform this action as some of your authorization data doesn't match.")
            expect(page).to have_content("Participation is restricted to participants with any of the following postal codes: 1234, 4567.")
            expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}.")
          end
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
        click_link "New proposal"
      end

      it "prompts user to check their authorization status" do
        expect(page).to have_content("Authorization required")
        expect(page)
          .to have_content("Your authorization has expired. In order to perform this action, you need to be reauthorized with \"Example authorization\"")
      end

      it "redirects to resume authorization when modal clicked" do
        click_link "Reauthorize with \"Example authorization\""

        expect(page).to have_content("Verify with Example authorization")
      end
    end

    context "when action not authorized" do
      let(:permissions) { nil }

      before do
        visit main_component_path(component)
        click_link "New proposal"
      end

      it "goes directly to action" do
        expect(page).to have_selector("p", text: "You are creating a proposal")
      end
    end
  end

  context "when using a workflow authorization", with_authorization_workflows: ["dummy_authorization_workflow"] do
    let(:authorization) { "dummy_authorization_workflow" }

    context "and action authorized" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_workflow: {} } } }
      end

      before do
        visit main_component_path(component)
        click_link "New proposal"
      end

      it "prompts user to authorize" do
        expect(page).to have_content("Authorization required")
        expect(page).to have_content("In order to perform this action, you need to be authorized with \"Dummy authorization workflow\"")
      end

      it "redirects to authorization when modal clicked" do
        click_link "Authorize with \"Dummy authorization workflow\""

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
        click_link "New proposal"
      end

      it "prompts user to check their authorization status" do
        expect(page).to have_content("Authorization is still in progress")
        expect(page)
          .to have_content("In order to perform this action, you need to be authorized with \"Dummy authorization workflow\", but your authorization is still in progress")
      end

      it "redirects to resume authorization when modal clicked" do
        click_link "Check your \"Dummy authorization workflow\" authorization progress"

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
        click_link "New proposal"
      end

      it "prompts user to check their authorization status" do
        expect(page).to have_content("Authorization required")
        expect(page)
          .to have_content("Your authorization has expired. In order to perform this action, you need to be reauthorized with \"Dummy authorization workflow\"")
      end

      it "redirects to resume authorization when modal clicked" do
        click_link "Reauthorize with \"Dummy authorization workflow\""

        expect(page).to have_content("DUMMY VERIFICATION ENGINE")
      end
    end

    context "when action not authorized" do
      let(:permissions) { nil }

      before do
        visit main_component_path(component)
        click_link "New proposal"
      end

      it "goes directly to action" do
        expect(page).to have_selector("p", text: "You are creating a proposal")
      end
    end
  end
end
